# Estudo Experimental de Planos de Execução e Estratégias de Acesso no Oracle

Este repositório documenta um estudo prático sobre comportamento de planos de execução no Oracle Database.

O objetivo não foi partir de uma regra previamente assumida como correta, mas analisar experimentalmente duas possibilidades de execução para consultas envolvendo `CUSTOMERS`, `ORDERS` e `ORDER_ITEMS`:

1. **Varredura completa da tabela (`FULL TABLE SCAN`) combinada com `HASH JOIN`;**
2. **Acesso orientado por índice (`INDEX RANGE SCAN`) combinado com `NESTED LOOPS`.**

Ao longo do experimento, as mesmas consultas foram executadas com diferentes níveis de seletividade temporal. Isso permitiu observar como a quantidade de dados selecionados altera o comportamento das estratégias.

## Estrutura

- `01-contexto-e-objetivo.md` — Motivação e perguntas investigadas.
- `02-metodologia.md` — Método de coleta e comparação.
- `03-resultados-joins.md` — Comparação entre estratégias de join.
- `04-resultados-sargabilidade.md` — Impacto de predicados SARGable.
- `05-conclusoes.md` — Interpretação e conclusões.
- `appendix-raw-results.md` — Resultados consolidados.

## Ideia central

O estudo parte de uma pergunta simples:

> Quando vale a pena localizar registros por índice e quando uma varredura completa pode ser uma estratégia mais adequada?

A resposta observada depende principalmente da seletividade da consulta e do custo total necessário para produzir o resultado.
