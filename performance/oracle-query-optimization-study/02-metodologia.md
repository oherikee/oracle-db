# 2. Metodologia experimental

## Consulta analisada

A consulta principal calcula o valor total dos itens de pedidos concluídos para clientes localizados nos estados de São Paulo, Rio de Janeiro e Paraná.

```sql
SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_amount
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON oi.order_id = o.order_id
WHERE c.state IN ('SP', 'RJ', 'PR')
  AND o.status = 'COMPLETED'
  AND o.order_date >= <janela temporal>
GROUP BY
    c.customer_id,
    c.customer_name;
```

## Variação de seletividade

A mesma consulta foi executada com diferentes janelas temporais:

- 7 dias;
- 14 dias;
- 30 dias;
- 60 dias;
- 90 dias.

A intenção foi alterar progressivamente a quantidade de pedidos selecionados e observar a resposta do plano de execução.

## Coleta dos planos reais

Após cada execução, o plano real foi coletado utilizando:

```sql
SELECT *
FROM TABLE(
    DBMS_XPLAN.DISPLAY_CURSOR(
        NULL,
        NULL,
        'ALLSTATS LAST'
    )
);
```

A análise considerou principalmente:

- `A-Rows`;
- `A-Time`;
- `Buffers`;
- método de acesso;
- método de join;
- diferença entre `E-Rows` e `A-Rows`.

## Estratégias comparadas

### Estratégia A — plano natural

O Oracle ficou livre para escolher o plano sem forçar o índice de `ORDER_ITEMS`.

Nos cenários observados, isso frequentemente resultou em:

- `TABLE ACCESS FULL`;
- `HASH JOIN`;
- `HASH GROUP BY`.

### Estratégia B — acesso orientado pelo índice

Foi utilizada a hint:

```sql
/*+ INDEX(oi idx_order_items_order_id) */
```

O objetivo da hint foi exclusivamente experimental: observar o comportamento de uma estratégia baseada em índice e compará-la com o plano naturalmente escolhido pelo otimizador.
