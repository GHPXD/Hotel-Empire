# M2 — evidências de simulação

Engine: Godot 4.7.2 stable, Windows, AMD Ryzen 7 5700U. Resultados locais; timings variam
com carga do sistema. Dados de memória são do processo inteiro, incluindo coleta/testes,
não memória isolada dos agentes. Datas: 2026-09-16.

| Cenário | Escopo | Resultado |
| --- | --- | --- |
| standard-30d.json | 30 dias, seed 123, chegadas contínuas | 374 reservas; 930 entregas; nenhuma falha |
| tower-burst-1000.json | 20 andares, burst inicial de 1000, 5 dias | 1000 saídas, 24 reservas; nenhuma falha |
| multi-seed-and-transport.json | 5 seeds × 5 dias; transporte 100/250/500/1000 | invariantes e entregas aprovadas |

O burst integrado teve média de apenas 16,7 agentes (pico 1010 contando equipe):
a maioria dos visitantes não encontrou vaga nas filas da recepção e saiu. Seu máximo
de tick foi 85,391 ms; não representa 1000 hóspedes ativos sustentados nem prova 60 FPS.
O stress de transporte mantém todos os passageiros até entregá-los, mas não executa
serviços, IA de hóspedes ou desenho. M8 precisa medir o jogo renderizado e carga sustentada.

Fila de recepção é medida desde chegada ao atendimento até saída desse estado,
incluindo check-in e abandono; serviço mede episódios concluídos, incluindo atendimento
imediato (zero espera). Episódios incompletos aparecem separadamente. Esperas são
observadas com resolução do tick (0,1s), não relógio de parede.

Reprodução: comandos de simulação e runner documentados em README.md. `failures: []`
prova somente as invariantes explicitamente implementadas em `SimulationRunner`.
O orçamento de teste é 250.000 para financiar templates; não é o caixa inicial do jogador.
