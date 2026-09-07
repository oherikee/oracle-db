# 5. Conclusões

## O que eu queria entender

O estudo começou com duas possibilidades que, à primeira vista, parecem representar filosofias opostas de execução.

A primeira consiste em aceitar a leitura de grandes conjuntos de dados e utilizar `HASH JOIN` para processá-los.

A segunda tenta evitar essa leitura utilizando índices e `NESTED LOOPS`.

O objetivo não era provar antecipadamente qual delas era a correta.

A intenção era observar o comportamento real e entender o que cada estratégia estava fazendo.

## Principal resultado

O uso de índice não pode ser tratado como sinônimo automático de melhor desempenho.

Nos cenários mais seletivos, a estratégia baseada em índice apresentou grande vantagem no tempo observado.

Entretanto, conforme a quantidade de pedidos aumentou, o número de buffers e de acessos necessários cresceu rapidamente.

A estratégia baseada em `FULL TABLE SCAN` apresentou um custo lógico mais estável porque a tabela `ORDER_ITEMS` era percorrida uma vez.

Isso demonstra que evitar uma varredura completa também possui um custo: o custo de localizar repetidamente os registros necessários.

## O que o experimento sugere

A pergunta:

> "Devo usar índice ou FULL TABLE SCAN?"

não possui uma resposta independente do contexto.

A resposta depende de:

- seletividade;
- cardinalidade;
- quantidade de acessos;
- método de join;
- distribuição física dos dados;
- cache;
- estatísticas.

Um `FULL TABLE SCAN` não representa automaticamente um problema.

Da mesma forma, um plano utilizando índice não representa automaticamente uma otimização.

## Sobre a escrita das consultas

O teste com `ORDER_DATE` mostrou que a forma do predicado influencia diretamente as estratégias disponíveis ao otimizador.

A aplicação de uma função sobre uma coluna indexada transformou um acesso seletivo de 20 buffers em uma operação que utilizou 2.672 buffers no ambiente testado.

## Consideração final

A principal conclusão deste estudo não é uma regra sobre quando usar índices.

É uma conclusão metodológica:

> **formular uma hipótese, executar o teste, coletar métricas reais e interpretar o plano de execução é mais confiável do que assumir que uma técnica é sempre superior.**

Esse foi o principal objetivo da investigação: compreender duas possibilidades de execução e observar como os dados e a seletividade alteram a decisão.
