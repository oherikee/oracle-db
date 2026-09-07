# Performance Studies

Esta pasta reúne estudos práticos sobre desempenho e otimização de consultas em banco de dados.

O objetivo não é apresentar regras absolutas sobre performance, mas investigar como diferentes estratégias se comportam em cenários específicos, analisando o comportamento real do banco de dados através de métricas de execução.

Cada estudo parte de uma pergunta ou hipótese e busca respondê-la por meio de experimentos controlados.

---

## Estudos

### [Oracle Query Optimization Study](./oracle-query-optimization-study/)

Estudo experimental sobre o comportamento do Oracle Database em diferentes estratégias de execução de consultas.

O experimento analisa principalmente duas situações:

- O comportamento de `FULL TABLE SCAN` e acesso por índice em consultas com diferentes níveis de seletividade.
- O impacto da aplicação de funções sobre colunas utilizadas em filtros, utilizando como exemplo a função `TRUNC()` sobre uma coluna de data.

Durante os experimentos são analisadas métricas como:

- Tempo de execução
- Logical I/O (`Buffers`)
- Physical Reads
- Cardinalidade estimada e real (`E-Rows` e `A-Rows`)
- Estratégias de join
- Mudanças no plano de execução
- Uso de índices

A proposta do estudo é observar como o otimizador do Oracle toma decisões e como fatores como seletividade, volume de dados e estrutura dos predicados podem influenciar o plano escolhido.

---

## Metodologia

Os estudos desta pasta seguem, sempre que possível, uma abordagem experimental:

1. Definição da pergunta ou hipótese.
2. Construção de um cenário de teste.
3. Execução das diferentes abordagens.
4. Coleta do plano de execução real.
5. Comparação das métricas.
6. Interpretação dos resultados.

Os resultados apresentados devem ser interpretados dentro do contexto de cada experimento.

Uma estratégia que apresenta melhor desempenho em um cenário específico não deve ser considerada automaticamente superior em todos os ambientes.

---

## Objetivo

Esta coleção funciona como um registro de estudos sobre comportamento e performance de banco de dados.

A intenção é desenvolver uma compreensão mais profunda sobre temas como:

- Oracle Optimizer
- Execution Plans
- Índices
- Selectividade
- Cardinalidade
- Join Methods
- Logical I/O
- Physical I/O
- Estatísticas
- Sargabilidade
- Query Rewriting

Cada novo estudo poderá explorar uma pergunta diferente, mantendo o foco na análise prática e na interpretação dos resultados.