# 3. Resultados: FULL TABLE SCAN + HASH JOIN versus índice + NESTED LOOPS

## Visão geral

O resultado mais importante do experimento foi que o uso do índice em `ORDER_ITEMS.ORDER_ID` não apresentou comportamento uniformemente superior.

Em janelas temporais pequenas, o acesso seletivo ao índice foi significativamente mais rápido.

À medida que a quantidade de pedidos selecionados aumentou, o custo acumulado dos acessos por índice cresceu rapidamente.

## Resultados consolidados

| Janela | Estratégia | Tempo observado | Buffers |
|---|---|---:|---:|
| 7 dias | FULL SCAN + HASH JOIN | 0,57 s | 18.147 |
| 7 dias | Índice + NESTED LOOPS | 0,07 s | 13.201 |
| 14 dias | FULL SCAN + HASH JOIN | 0,61 s | 18.147 |
| 14 dias | Índice + NESTED LOOPS | 0,08 s | 19.892 |
| 30 dias | FULL SCAN + HASH JOIN | 0,67 s | 18.147 |
| 30 dias | Índice + NESTED LOOPS | 0,11 s | 35.378 |
| 60 dias | FULL SCAN + HASH JOIN | 0,71 s | 18.147 |
| 60 dias | Índice + NESTED LOOPS | 0,25 s | 64.460 |
| 90 dias | FULL SCAN + HASH JOIN | 0,68 s | 18.147 |
| 90 dias | Índice + NESTED LOOPS | 0,24 s | 92.665 |

## Janela de 7 dias

Com a janela mais seletiva, a estratégia baseada em índice apresentou vantagem clara.

O plano realizou `INDEX RANGE SCAN` para localizar os registros necessários e utilizou `NESTED LOOPS` para recuperar os itens relacionados.

A alternativa baseada em `FULL TABLE SCAN` percorreu aproximadamente três milhões de linhas de `ORDER_ITEMS`, independentemente de apenas uma pequena parcela dos pedidos participar do resultado.

## Crescimento do custo da estratégia por índice

À medida que a janela temporal aumentou, o número de acessos necessários também aumentou:

| Janela | Execuções do INDEX RANGE SCAN | Acessos por ROWID |
|---|---:|---:|
| 7 dias | 1.389 | 4.108 |
| 14 dias | 2.760 | 8.097 |
| 30 dias | 5.831 | 17.377 |
| 60 dias | 11.663 | 34.787 |
| 90 dias | 17.436 | 52.010 |

A estratégia por índice continuou apresentando menor tempo observado no ambiente do teste, mas o número de buffers cresceu de aproximadamente 13 mil para mais de 92 mil.

A estratégia baseada em varredura completa permaneceu próxima de 18.147 buffers.

## Interpretação

Os dois métodos possuem perfis de custo diferentes.

A varredura completa pode ser interpretada como:

> Ler um grande conjunto uma vez e processá-lo sequencialmente.

A estratégia baseada em índice pode ser interpretada como:

> Evitar a leitura completa, pagando o custo de localizar repetidamente cada conjunto necessário.

Quando poucas linhas são necessárias, evitar a leitura completa pode ser extremamente vantajoso.

Quando o número de buscas aumenta, o custo acumulado dos acessos pontuais também cresce.

O experimento não estabelece um ponto de corte universal. Esse ponto depende do ambiente, da distribuição dos dados, do cache e das estatísticas disponíveis.
