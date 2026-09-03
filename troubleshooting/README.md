# Oracle Database Troubleshooting

Coleção de casos de troubleshooting relacionados ao Oracle Database.

O objetivo desta seção é documentar problemas de forma estruturada, dando ênfase ao processo de investigação e diagnóstico.

## Abordagem

Um problema de banco de dados raramente deve ser tratado apenas pelo erro apresentado.

A abordagem utilizada aqui é:

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

Sempre que possível, são utilizadas evidências provenientes do próprio Oracle, como:

- Views dinâmicas (`V$`);
- Views do dicionário (`DBA_*`, `ALL_*`, `USER_*`);
- Alert Log;
- Trace Files;
- Logs de ferramentas Oracle;
- Logs do sistema operacional;
- Status de processos;
- Arquivos de configuração;
- Histórico de comandos.

## Casos documentados

| Caso | Descrição |
|---|---|
| [ORA-01078 — Missing Parameter File](./ora-01078-missing-parameter-file/) | Instância não consegue iniciar porque o arquivo de parâmetros esperado não está disponível. |
| [ORA-01589 — Database Requires RESETLOGS or NORESETLOGS](./ora-01589-db-open/) | Database permanece em MOUNTED e exige `RESETLOGS` ou `NORESETLOGS` para ser aberta. |

> Novos casos serão adicionados conforme forem confrontados.

## Estrutura dos casos

Cada incidente pode conter:

```text
caso/
├── README.md
├── commands.sql
├── logs/
└── evidence/
```

A estrutura pode variar de acordo com o caso e com os materiais relevantes para sua reprodução ou análise.

## Objetivo

O objetivo não é criar uma lista de erros Oracle.

É construir um histórico de **problemas investigados**, permitindo consultar posteriormente:

- O que aconteceu;
- Como o problema foi identificado;
- Quais evidências foram relevantes;
- Por que determinada solução foi escolhida;
- Como a solução foi validada.

Isso também permite utilizar os casos como material de estudo e referência para situações futuras.
