# 1. Contexto e objetivo

## Motivação

A otimização de consultas SQL é frequentemente apresentada por meio de regras simplificadas. Uma das mais comuns é a ideia de que um índice deve sempre ser utilizado quando uma coluna participa de filtros ou joins.

Na prática, o Oracle Optimizer não trata o uso de índices como um objetivo em si. Um índice é apenas uma das possíveis estratégias para acessar os dados.

Este estudo foi iniciado justamente para investigar essa diferença experimentalmente.

A consulta analisada relaciona três tabelas:

- `CUSTOMERS`;
- `ORDERS`;
- `ORDER_ITEMS`.

A tabela `ORDER_ITEMS`, com aproximadamente três milhões de linhas, representa o maior volume de dados da consulta.

Meu interesse inicial não era provar que uma estratégia era superior à outra. Eu queria analisar duas possibilidades e compreender o comportamento de cada uma.

## Primeira possibilidade: processar grandes conjuntos de dados

Uma estratégia possível consiste em realizar:

1. `FULL TABLE SCAN`;
2. `HASH JOIN`;
3. agregações com `HASH GROUP BY`.

Essa abordagem pode parecer inicialmente contraintuitiva porque pode ler uma tabela inteira mesmo quando apenas parte das linhas participa do resultado.

Entretanto, quando uma quantidade significativa de dados é necessária, a leitura sequencial pode ser mais eficiente do que milhares de acessos individuais.

## Segunda possibilidade: localizar pedidos e buscar seus itens

A segunda estratégia consiste em:

1. reduzir inicialmente o conjunto de pedidos;
2. utilizar os identificadores dos pedidos selecionados;
3. acessar `ORDER_ITEMS` por meio do índice `IDX_ORDER_ITEMS_ORDER_ID`;
4. recuperar os itens relacionados utilizando `NESTED LOOPS`.

Essa estratégia evita a leitura completa de `ORDER_ITEMS`, mas introduz outro custo: múltiplos acessos ao índice e à tabela.

A pergunta investigada foi:

> **Como a seletividade dos filtros altera o ponto de equilíbrio entre uma estratégia baseada em FULL TABLE SCAN + HASH JOIN e outra baseada em índice + NESTED LOOPS?**

## Questão complementar

Também foi analisado o impacto da escrita de predicados temporais sobre o uso de índices.

Foram comparadas duas condições logicamente equivalentes:

```sql
order_date >= TRUNC(SYSDATE) - 7
AND order_date < TRUNC(SYSDATE)
```

e:

```sql
TRUNC(order_date) >= TRUNC(SYSDATE) - 7
AND TRUNC(order_date) < TRUNC(SYSDATE)
```

O objetivo foi observar como a aplicação de uma função sobre uma coluna indexada altera as estratégias disponíveis ao otimizador.
