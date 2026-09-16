# Hipóteses de gestão M3

Escopo: hotel pequeno, protótipo desktop. O upgrade deve melhorar a operação sem
consumir área ou perder ocupantes, cobrando investimento e manutenção adicionais.
Os valores abaixo são hipóteses iniciais, não economia final validada.

Fonte executável: `data/upgrades/*.tres`. Bônus são absolutos sobre a base, não somados
entre níveis. Custo é pago em cada compra; manutenção é cobrada por dia de simulação.

| Instalação | N2 | N3 |
| --- | --- | --- |
| Recepção | $400; manutenção +4; duração ×0,75 | $700; manutenção +9; duração ×0,5 |
| Quarto | $350; preço +35; manutenção +4; satisfação +2 | $600; preço +70; manutenção +9; satisfação +4 |
| Bistrô | $650; capacidade +1; preço +6; manutenção +7; duração ×0,85; satisfação +2 | $1000; capacidade +2; preço +12; manutenção +14; duração ×0,7; satisfação +4 |
| Elevador | $900; capacidade +2; manutenção +10; velocidade ×1,25 | $1500; capacidade +4; manutenção +22; velocidade ×1,6 |

O quarto N2 exige dez reservas para recuperar $350 apenas pela receita incremental
de $35, antes da manutenção extra e de mudanças de demanda. Isso não promete retorno
líquido. O bistrô passa de capacidade teórica 3/8 = 0,375 atendimento/s para
5/5,6 ≈ 0,893 no N3, antes de deslocamentos, falta de demanda e restrições de saldo.
Preço mais alto pode tornar o serviço inacessível a hóspedes com pouco dinheiro.

Evidência determinística: o teste de gestão confirma redução real de check-in e,
para 20 passageiros entre dois andares com a mesma origem, transporte de 279 para
125 ticks no elevador N3. Esses resultados não medem lucro nem filas em toda topologia.
Os testes de cinco seeds existentes são regressões de operação sem estratégia de upgrades.

Próximo experimento econômico: comparar construir versus melhorar durante 30 dias,
com cinco seeds e o mesmo orçamento; registrar investimento, custo de oportunidade,
lucro, ocupação, rejeições por saldo, espera e satisfação. Se uma opção dominar em
todos os cenários, revisar custos/efeitos e repetir a comparação. Manter histórico
em Git para reverter os valores. M3 não ajusta números apenas para produzir lucro.

Telemetria atual é local: ledger, snapshots, relatórios e testes. Não há coleta remota.
Registrar ofertas de upgrade disponíveis e decisões de jogadores em playtests futuros
ajudará a distinguir uma opção pouco visível de uma opção economicamente ruim.
