# Experimento de tarifas

Pergunta: tarifas globais fixas de 75%, 100% e 125% criam diferenças de caixa,
atendimento e reputação no hotel inicial? Ainda não há evidência humana de que
os jogadores entendem e aproveitam essa decisão.

Contrato de avaliação: em hotéis novos de dois e oito quartos, com $12.000,
uma recepção, um restaurante, um elevador e um funcionário de cada função,
comparar 30 dias nas seeds 1, 17 e 123. Não comprar upgrades nem expandir após
abrir. Aplicar o mesmo percentual aos quartos e ao restaurante. Usar 100% como
referência. Não exigir lucro igual das opções. Sinalizar para investigação se
uma política superar as demais em caixa e reputação em todos os contextos sem
reduzir atendimento, ou se a referência de oito quartos ficar insolvente.

Guardas: conservação de dinheiro, referências e capacidade válidas; cinco
round-trips JSON por cenário com 120 ticks de continuidade idêntica. Resultados
de insolvência não abortam a medição. Ocupação é a soma dos ticks com quarto
reservado/ocupado dividida por quartos × ticks; não mede presença física no
quarto. Caixa mínimo inclui o instante após construção. O lucro é operacional
acumulado, sem subtrair investimento inicial em construção/contratação.

Reprodução: executar `tests/tariff_scenarios.gd` no Godot em modo headless com
APPDATA isolado. Saída bruta em `.runtime/tariff-scenarios.json`. O experimento
fica fora da bateria rápida; custa 648.000 ticks mais 10.800 ticks de comparação
de saves. Não mede hotel expandindo, preços por sala mistos ou chegadas elásticas
em função de preço. Seeds iguais começam com o mesmo RNG, mas podem divergir
durante a simulação conforme a política muda o comportamento.
