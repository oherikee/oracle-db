# 4. Resultados: SARGabilidade e funções sobre colunas indexadas

## Predicado direto sobre a coluna

A primeira consulta utilizou diretamente a coluna indexada:

```sql
SELECT COUNT(*)
FROM orders
WHERE order_date >= TRUNC(SYSDATE) - 7
  AND order_date < TRUNC(SYSDATE);
```

Resultado observado:

- 6.322 linhas;
- aproximadamente 0,01 s;
- 20 buffers;
- `INDEX RANGE SCAN`.

## Função aplicada sobre a coluna

A segunda consulta foi escrita como:

```sql
SELECT COUNT(*)
FROM orders
WHERE TRUNC(order_date) >= TRUNC(SYSDATE) - 7
  AND TRUNC(order_date) < TRUNC(SYSDATE);
```

O resultado lógico foi o mesmo: 6.322 linhas.

Entretanto, o plano mudou:

- aproximadamente 0,36 s;
- 2.672 buffers;
- `INDEX FAST FULL SCAN`.

## Comparação

| Forma do predicado | Operação | Buffers | Tempo |
|---|---|---:|---:|
| Condição direta em `ORDER_DATE` | INDEX RANGE SCAN | 20 | 0,01 s |
| `TRUNC(ORDER_DATE)` no predicado | INDEX FAST FULL SCAN | 2.672 | 0,36 s |

## Interpretação

A aplicação de `TRUNC` diretamente sobre a coluna indexada alterou a capacidade do Oracle de utilizar o índice para navegar seletivamente pelo intervalo.

Quando semanticamente possível, é preferível preservar a coluna sem função e construir o intervalo nos valores de comparação.

Por exemplo:

```sql
order_date >= TRUNC(SYSDATE)
AND order_date < TRUNC(SYSDATE) + 1
```

O experimento mostra que duas consultas logicamente equivalentes podem produzir estratégias de acesso significativamente diferentes apenas pela forma como o predicado é escrito.
