Este projeto de Estacionamento em VHDL consiste em gerenciar 3 vagas usando um sensor de proximidade, quando um carro chega na vaga,
o tempo começa a contar o tempo em que o carro permanece na vaga. Após o carro sair, é feito o pagamento, onde o valor depende do tempo
da estadia do carro na vaga, até 7 segundos, é o valor dos segundos gastos na vaga, caso mais, é um valor fixo de 7 reais.
Importante mencionar que apenas uma vaga pode pagar por vez, e o operador escolhe quem vai pagar aleatóriamente entre as 3 vagas.
Quando todas as vagas são ocupadas, um servo motor é acionado para fechar a cancela.
