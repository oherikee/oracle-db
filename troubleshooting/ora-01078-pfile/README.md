# ORA-01078 --- PFILE não localizado durante o STARTUP

## Cenário

Após a criação de uma database Oracle 19c utilizando o DBCA, foi
realizada uma tentativa de iniciar a instância normalmente:

``` sql
STARTUP;
```

O Oracle retornou:

``` text
ORA-01078: failure in processing system parameters
LRM-00109: could not open parameter file
'/u01/app/oracle/product/19.0.0/dbhome_1/dbs/initORCL.ora'
```

O erro indicava que o Oracle não conseguiu localizar o arquivo de
parâmetros esperado para a instância `ORCL`.

## Investigação

O primeiro passo foi verificar o diretório padrão de arquivos de
inicialização:

``` bash
ls -lah $ORACLE_HOME/dbs
```

Nesse diretório não havia um `spfileORCL.ora` nem o `initORCL.ora`
esperado.

Em seguida, foram procurados arquivos de inicialização dentro do
ambiente Oracle:

``` bash
find /u01 -name "init*.ora" -o -name "spfile*.ora"
```

Durante a investigação foi localizado um PFILE temporário gerado pelo
DBCA:

``` text
/u01/app/oracle/cfgtoollogs/dbca/orcl/initorclTemp.ora
```

## Solução temporária

Com o PFILE localizado, foi possível iniciar a instância informando
explicitamente o arquivo de parâmetros:

``` sql
STARTUP PFILE='/u01/app/oracle/cfgtoollogs/dbca/orcl/initorclTemp.ora';
```

A instância foi iniciada utilizando o PFILE.

## Criação do SPFILE

Para permitir que a instância fosse iniciada normalmente através de
`STARTUP`, foi criado um SPFILE a partir do PFILE:

``` sql
CREATE SPFILE
FROM PFILE='/u01/app/oracle/cfgtoollogs/dbca/orcl/initorclTemp.ora';
```

A configuração foi então validada através de:

``` sql
SHOW PARAMETER spfile;
```

## Validação

Após a criação do SPFILE, a instância foi reiniciada:

``` sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

O Oracle passou a localizar o arquivo de parâmetros automaticamente.

Nesse momento, a investigação avançou para a próxima etapa: embora a
instância estivesse iniciada, a database permanecia em `MOUNTED`.

A tentativa de abertura:

``` sql
ALTER DATABASE OPEN;
```

resultou posteriormente em:

``` text
ORA-01589: must use RESETLOGS or NORESETLOGS option for database open
```

Esse segundo problema levou à investigação dos logs gerados pelo DBCA e
à descoberta de que a database havia sido criada utilizando a Seed
Database, RMAN restore e recriação do control file.

## O que este caso demonstra

-   O `ORA-01078` pode indicar que o Oracle não conseguiu processar os
    parâmetros necessários para iniciar a instância;
-   O `LRM-00109` mostra especificamente que o arquivo de parâmetros
    esperado não foi localizado;
-   O PFILE pode ser utilizado explicitamente através da cláusula
    `PFILE` no `STARTUP`;
-   Um SPFILE pode ser criado a partir de um PFILE;
-   A criação do SPFILE permite que o Oracle localize automaticamente os
    parâmetros durante um `STARTUP` normal;
-   Durante um troubleshooting, resolver o primeiro erro não significa
    necessariamente que o problema completo foi solucionado;
-   A investigação pode avançar por diferentes camadas até chegar à
    causa do comportamento observado.

## Comandos utilizados

### Localização dos arquivos

``` bash
ls -lah $ORACLE_HOME/dbs

find /u01 -name "init*.ora" -o -name "spfile*.ora"
```

### Inicialização utilizando PFILE

``` sql
STARTUP PFILE='/u01/app/oracle/cfgtoollogs/dbca/orcl/initorclTemp.ora';
```

### Criação do SPFILE

``` sql
CREATE SPFILE
FROM PFILE='/u01/app/oracle/cfgtoollogs/dbca/orcl/initorclTemp.ora';
```

### Validação

``` sql
SHOW PARAMETER spfile;
```

``` sql
SHUTDOWN IMMEDIATE;
STARTUP;
```

## Relação com o caso ORA-01589

O problema do PFILE foi a primeira etapa do troubleshooting realizado
durante a criação da database.

O fluxo completo acabou sendo:

``` text
DBCA cria a database
        ↓
STARTUP
        ↓
ORA-01078 / LRM-00109
        ↓
Localização do PFILE temporário
        ↓
STARTUP PFILE
        ↓
CREATE SPFILE
        ↓
STARTUP normal
        ↓
Database permanece MOUNTED
        ↓
ORA-01589
        ↓
Investigação dos logs do DBCA
        ↓
Seed Database + RMAN + CREATE CONTROLFILE
        ↓
OPEN RESETLOGS
        ↓
Database READ WRITE
```
