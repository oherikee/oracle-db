# RMAN Recovery — Datafile Restore and Media Recovery

## Objetivo

Demonstrar, em um cenário controlado, a diferença entre **RESTORE** e **RECOVER** usando Oracle Database 19c e RMAN.

O cenário simula a perda física de um datafile dedicado ao laboratório, restaura o arquivo a partir de um backup RMAN e aplica archived redo para recuperar as alterações realizadas depois do backup.

## Ambiente

- Oracle Database 19c
- CDB: `ORCL`
- PDB: `ORCLPDB1`
- Tablespace: `RECOVERY_LAB`
- Datafile: `14`
- Usuário: `RECOVERY_LAB`
- Tabela: `RECOVERY_DATA`
- RMAN usando o control file como repositório
- FRA: `/u01/fra`

Datafile:

```text
/u01/oradata/ORCL/5AE6447A959B4AD1E0636701A8C046D2/datafile/recovery_lab01.dbf
```

## 1. Baseline

`RECOVERY_LAB` estava `ONLINE` e `PERMANENT`.

O datafile 14 estava `ONLINE` e `READ WRITE`.

O backup RMAN relevante foi o **Backup Set 4**, contendo o datafile 14.

Checkpoint do backup:

```text
SCN 2547143
```

Estado lógico inicial:

```text
TOTAL_ROWS = 1000
MIN_ID     = 1
MAX_ID     = 1000
```

## 2. Alterações após o backup

### T1

```sql
INSERT INTO recovery_data (id, description, created_at)
SELECT
    1000 + LEVEL,
    'T1 - dado criado após o backup',
    SYSDATE
FROM dual
CONNECT BY LEVEL <= 500;

COMMIT;
```

Estado:

```text
TOTAL_ROWS = 1500
MIN_ID     = 1
MAX_ID     = 1500
```

### T2

```sql
INSERT INTO recovery_data (id, description, created_at)
SELECT
    1500 + LEVEL,
    'T2 - segundo conjunto pós-backup',
    SYSDATE
FROM dual
CONNECT BY LEVEL <= 500;

COMMIT;
```

Estado:

```text
TOTAL_ROWS = 2000
MIN_ID     = 1
MAX_ID     = 2000
```

## 3. Archived redo

Sequências relevantes observadas:

```text
SEQ 14: 2547071 → 2547114
SEQ 15: 2547114 → 2550915
SEQ 16: 2550915 → 2550927
SEQ 17: 2550927 → 2551596
SEQ 18: 2551596 → 2551629
```

O backup do datafile estava em `SCN 2547143`, portanto as alterações posteriores dependiam de redo posterior ao backup.

## 4. Simulação da perda

O banco foi desligado e o datafile foi movido para fora do caminho original:

```bash
mv recovery_lab01.dbf recovery_lab01.dbf.lost
```

O banco conseguiu abrir, mas o diagnóstico mostrou:

```text
V$DATAFILE
FILE# = 14
STATUS = ONLINE
CHECKPOINT_CHANGE# = 2551819
```

Enquanto o header físico retornou:

```text
V$DATAFILE_HEADER
FILE# = 14
ERROR = FILE NOT FOUND
```

E:

```text
V$RECOVER_FILE
FILE# = 14
ONLINE_STATUS = ONLINE
ERROR = FILE NOT FOUND
```

### Diagnóstico

O control file ainda possuía o registro do datafile, mas o arquivo físico não estava disponível no filesystem.

## 5. RESTORE

Com RMAN:

```rman
RESTORE DATAFILE 14;
```

O RMAN utilizou o Backup Set 4 e restaurou o datafile para o caminho original.

Após o restore:

```text
CHECKPOINT_CHANGE# = 2547143
FUZZY = NO
```

Isso demonstra que o RESTORE devolveu o datafile ao estado correspondente ao backup.

## 6. RECOVER

Em seguida:

```rman
RECOVER DATAFILE 14;
```

O RMAN encontrou os archived logs disponíveis e realizou a recuperação.

A saída indicou aplicação das sequências 15 e 16 e:

```text
media recovery complete
```

As sequências 17 e 18 estavam disponíveis, mas não foram necessárias para completar a recuperação daquele datafile.

## 7. Validação

Após a recuperação:

```sql
SELECT
    COUNT(*) AS total_rows,
    MIN(id) AS min_id,
    MAX(id) AS max_id
FROM recovery_data;
```

Resultado:

```text
TOTAL_ROWS = 2000
MIN_ID     = 1
MAX_ID     = 2000
```

Validação dos registros criados após o backup:

```sql
SELECT
    MIN(id) AS min_id,
    MAX(id) AS max_id,
    COUNT(*) AS total_rows
FROM recovery_data
WHERE id BETWEEN 1001 AND 2000;
```

Resultado:

```text
MIN_ID     = 1001
MAX_ID     = 2000
TOTAL_ROWS = 1000
```

Portanto, os 1000 registros criados após o backup estavam presentes depois da recuperação.

## 8. Conclusão técnica

### RESTORE

Recupera a cópia física do datafile a partir de um backup.

No cenário, o datafile voltou ao checkpoint `2547143`.

### RECOVER

Aplica o redo necessário para levar o datafile restaurado a um estado posterior e consistente.

O resultado foi demonstrado pela presença dos 2000 registros, incluindo os 1000 criados depois do backup.

Fluxo:

```text
BACKUP
  ↓
Datafile @ SCN 2547143
  ↓
RESTORE
  ↓
Datafile reconstruído @ SCN 2547143
  ↓
RECOVER
  ↓
Archived redo aplicado
  ↓
Datafile recuperado
  ↓
Validação: 2000 registros
```

## 9. Próximo cenário sugerido

O próximo laboratório pode introduzir uma falha na cadeia de archived redo:

```text
RESTORE
   ↓
RECOVER
   ↓
archive necessário não encontrado
   ↓
investigação de thread / sequence / SCN
   ↓
LIST BACKUP OF ARCHIVELOG
   ↓
archive localizado em backup RMAN
   ↓
RESTORE ARCHIVELOG
   ↓
RECOVER novamente
   ↓
validação
```

Esse segundo cenário representa um troubleshooting mais completo de uma falha de cadeia de archived redo.

## Conceitos demonstrados

- RMAN backup
- Backup Set
- Datafile restore
- Media recovery
- Archived redo
- SCN
- Checkpoint do datafile
- `V$DATAFILE`
- `V$DATAFILE_HEADER`
- `V$RECOVER_FILE`
- `V$ARCHIVED_LOG`
- Validação pós-recovery
- Diferença entre RESTORE e RECOVER
- Relação entre backup físico e redo
