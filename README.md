# Oracle Database

Repositório dedicado a estudos, experimentos, troubleshooting e casos práticos relacionados à administração do Oracle Database.

O objetivo é documentar situações de administração e diagnóstico de forma reproduzível, registrando não apenas os comandos utilizados, mas também o contexto, as evidências coletadas, o raciocínio utilizado para chegar ao diagnóstico e a validação da solução.

Este repositório será continuamente alimentado com novos estudos, experimentose casos encontrados em ambientes reais.

## Objetivos

Este repositório tem como objetivo aprofundar meus conhecimentos em administração do Oracle Database, desenvolver minha capacidade de troubleshooting, praticar processos de backup, restore e recovery com RMAN, estudar performance e diagnóstico de problemas, além de documentar procedimentos administrativos e construir uma base de referência para consultas futuras. Também será utilizado para registrar casos reais e experiências práticas adquiridas ao longo da minha carreira.

## Estrutura

```text
oracle-db/
│
├── administration/
│   ├── users-roles-privileges/
│   ├── tablespaces/
│   ├── datafiles/
│   ├── pdbs/
│   └── startup-shutdown/
│
├── rman/
│   ├── backup/
│   ├── restore/
│   ├── recovery/
│   └── pitr/
│
├── performance/
│   ├── execution-plans/
│   ├── statistics/
│   ├── indexes/
│   ├── sql-tuning/
│   └── wait-events/
│
├── troubleshooting/
│   ├── ora-01078-missing-parameter-file/
│   ├── ora-01589-db-open/
│   └── ...
│
└── README.md
```

> A estrutura pode evoluir conforme novos temas e casos forem documentados.
> Apenas documentações revisadas estarão visíveis.

## Metodologia

Sempre que possível, os casos são documentados seguindo o fluxo:

```text
Cenário
   ↓
Sintoma
   ↓
Coleta de evidências
   ↓
Diagnóstico
   ↓
Validação
```

## Principais áreas

### Administração

Procedimentos relacionados à administração do Oracle Database, incluindo:

- Instâncias;
- Startup e shutdown;
- Usuários;
- Roles e privilégios;
- Tablespaces;
- Datafiles;
- Control files;
- Redo logs;
- UNDO;
- PDBs e CDBs;
- Oracle Net e Listener.

### RMAN

Estudos e cenários envolvendo:

- Backup;
- Restore;
- Recovery;
- Archivelog;
- Incremental backup;
- Point-in-Time Recovery (PITR);
- Recuperação após falhas.

### Performance

Estudos relacionados à identificação e análise de problemas de desempenho:

- Execution Plans;
- CBO;
- Estatísticas;
- Índices;
- SQL Tuning;
- SGA e PGA;
- Wait Events;
- AWR;
- ASH;
- Diagnóstico de SQL.

### Troubleshooting

Registro de problemas encontrados durante estudos ou em ambientes reais, sempre que possível contendo:

- Erro ou comportamento observado;
- Evidências;
- Processo de investigação;
- Diagnóstico;
- Solução;
- Validação;
- Impactos e considerações.

Este repositório existe para transformar conhecimento teórico em experiência prática e documentada.
