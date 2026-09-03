# ORA-01589 — Database requires RESETLOGS or NORESETLOGS

## Cenário

Durante a criação de uma database Oracle 19c utilizando o DBCA, a instância foi iniciada e montada normalmente.

Ao tentar abrir a database manualmente:

```sql
ALTER DATABASE OPEN;
```

o Oracle retornou:

```text
ORA-01589: must use RESETLOGS or NORESETLOGS option for database open
```

## Sintoma

A instância estava em estado `OPEN`, porém a database permanecia em:

```text
OPEN_MODE
---------
MOUNTED
```

A tentativa de abertura normal resultava em:

```text
ORA-01589: must use RESETLOGS or NORESETLOGS option for database open
```

## Investigação

### 1. Estado da database

Foi consultado:

```sql
SELECT name,
       open_mode,
       log_mode,
       database_role
FROM v$database;
```

Resultado:

```text
NAME      OPEN_MODE   LOG_MODE      DATABASE_ROLE
--------- ----------- ------------  ----------------
ORCL      MOUNTED     NOARCHIVELOG  PRIMARY
```

A instância estava operacional, mas a database ainda não estava aberta.

### 2. Estado dos datafiles

Foi realizada uma verificação dos headers dos datafiles:

```sql
SELECT file#,
       recover,
       fuzzy,
       checkpoint_change#,
       checkpoint_time
FROM v$datafile_header
ORDER BY file#;
```

Os datafiles apresentavam `RECOVER = NO` e `FUZZY = NO`, sem erros nos headers.

Também foi consultada:

```sql
SELECT *
FROM v$recover_file;
```

Não foram identificados erros de recuperação pendentes.

### 3. Investigação dos logs do DBCA

Como o erro não podia ser explicado apenas pelo estado atual dos datafiles, os logs gerados pelo DBCA foram analisados.

O processo de criação mostrou que o DBCA utilizou a Seed Database e executou uma etapa de:

```text
RMAN_RESTORE_FROM_OFFLINE_BACKUP
```

Os datafiles foram restaurados para:

```text
/u01/oradata/ORCL/
```

incluindo:

```text
system01.dbf
sysaux01.dbf
undotbs01.dbf
users01.dbf
```

O log também registrou a recriação do control file:

```text
Create controlfile reuse set database "orcl"
```

### 4. Evidência decisiva

A etapa final do processo de criação registrada pelo DBCA foi:

```sql
ALTER DATABASE "orcl" OPEN RESETLOGS;
```

Isso explicou o comportamento observado posteriormente.

A database havia sido criada através de um processo de clone baseado na Seed Database, envolvendo restore dos datafiles e recriação do control file.

Nesse contexto, o `RESETLOGS` fazia parte do processo de criação da database.

## Diagnóstico

O `ORA-01589` não indicava, isoladamente, que os datafiles estavam corrompidos ou que um recovery convencional estava pendente.

O banco havia passado por um processo de criação baseado em:

```text
Seed Database
      ↓
RMAN Restore
      ↓
CREATE CONTROLFILE
      ↓
RESETLOGS
      ↓
Database OPEN
```

A exigência de `RESETLOGS` estava relacionada ao processo de criação/clonagem realizado pelo DBCA.

## Solução

Após confirmar o processo realizado pelo DBCA através dos logs, a database foi aberta utilizando:

```sql
ALTER DATABASE OPEN RESETLOGS;
```

A database passou para:

```text
OPEN_MODE
---------
READ WRITE
```

## Validação

O estado final foi validado através de:

```sql
SELECT instance_name,
       status,
       version
FROM v$instance;
```

e:

```sql
SELECT name,
       open_mode,
       log_mode,
       database_role,
       cdb
FROM v$database;
```

Resultado esperado:

```text
INSTANCE_NAME  STATUS
-------------- ------
ORCL           OPEN
```

e:

```text
NAME  OPEN_MODE   DATABASE_ROLE
----- ----------- -------------
ORCL  READ WRITE  PRIMARY
```

## O que este caso demonstra

Este caso reforçou alguns pontos importantes de administração Oracle:

- Uma instância pode estar iniciada enquanto a database permanece apenas em `MOUNTED`;
- `STARTUP` passa por diferentes estados: `NOMOUNT`, `MOUNT` e `OPEN`;
- `ORA-01589` não deve ser tratado automaticamente com `RESETLOGS`;
- O contexto da criação ou recuperação da database é fundamental para determinar a ação correta;
- Os logs das ferramentas Oracle podem ser essenciais para entender operações realizadas automaticamente;
- O DBCA pode utilizar a Seed Database e RMAN durante a criação de uma database;
- `RESETLOGS` possui implicações específicas e deve ser utilizado de acordo com o estado da database e o processo que levou a esse estado.

## Evidências

Os principais registros utilizados durante a investigação foram:

- [trace.log](/logs/trace.log)

Entre as evidências encontradas estão:

```text
RMAN_RESTORE_FROM_OFFLINE_BACKUP
```

```text
Create controlfile reuse set database "orcl"
```

e:

```sql
ALTER DATABASE "orcl" OPEN RESETLOGS;
```

## Referências

- [Oracle Database 19c Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/19/index.html)
- [Oracle Database Backup and Recovery User's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/)
- [Oracle Database Administrator's Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/)