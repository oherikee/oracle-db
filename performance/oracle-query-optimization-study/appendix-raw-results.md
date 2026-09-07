# Apêndice — Resultados experimentais consolidados

## Distribuição observada de pedidos concluídos

| Período | Quantidade |
|---|---:|
| Últimos 7 dias | 4.737 |
| Últimos 30 dias | 19.553 |
| Últimos 3 meses | 59.281 |
| Últimos 12 meses | 233.734 |
| Total | 700.000 |

## Comparação das estratégias

| Janela | FULL SCAN + HASH JOIN | Buffers | Índice + NESTED LOOPS | Buffers |
|---|---:|---:|---:|---:|
| 7 dias | 0,57 s | 18.147 | 0,07 s | 13.201 |
| 14 dias | 0,61 s | 18.147 | 0,08 s | 19.892 |
| 30 dias | 0,67 s | 18.147 | 0,11 s | 35.378 |
| 60 dias | 0,71 s | 18.147 | 0,25 s | 64.460 |
| 90 dias | 0,68 s | 18.147 | 0,24 s | 92.665 |

## Teste de SARGabilidade

| Consulta | Linhas | Operação | Buffers | Tempo |
|---|---:|---|---:|---:|
| Predicado direto em `ORDER_DATE` | 6.322 | INDEX RANGE SCAN | 20 | 0,01 s |
| `TRUNC(ORDER_DATE)` no predicado | 6.322 | INDEX FAST FULL SCAN | 2.672 | 0,36 s |

## Observação

Os resultados representam o comportamento observado no ambiente do experimento e não devem ser interpretados como valores universais para qualquer instalação Oracle.
