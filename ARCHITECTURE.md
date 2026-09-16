# Arquitetura

- Definitions: Resources `.tres` imutáveis; catálogo com IDs estáveis.
- Estado de partida: modelos RefCounted pertencentes à sessão, sem autoloads.
- Economy: único escritor de caixa e ledger; separa investimento de resultado operacional.
- Hotel: proprietário de andares, salas e validação de construção.
- Simulation: tick fixo de 0,1 s, RNG central com seed; coordena sistemas especializados.
- Entidades: dados e estados; apresentação renderiza o modelo sem comandar regras.
- UI: comandos semânticos para sessão; signals/notificações e leitura inicial do modelo.
- Save: snapshots primitivos versionados, validação completa antes de trocar a sessão.

Dependências: apresentação → sessão → sistemas/modelos → definições. Nenhum sistema de
simulação depende de Control, sprites ou SceneTree. Transporte hierárquico por andar e
elevador; sem navmesh ou AStar global. Autoload só quando a vida útil exigir.

Implementar somente interfaces necessárias ao marco atual. Pooling, áudio e frameworks
de eventos/conquistas aguardam necessidade demonstrada.

## Implementado no slice

`HotelSession` possui Economy, HotelModel, TransportSystem, GuestSystem e EmployeeSystem.
IDs estáveis ligam ActorState, RoomState e ElevatorState. IA/transporte rodam a 10 Hz;
render redesenha os placeholders a cada frame. Relógio vem de ticks inteiros para evitar
deriva acumulada. O RNG é exclusivo da sessão, nunca o gerador global.

`SessionSnapshot` v1 define campos explicitamente e valida tipos, limites, geometria,
catálogo e referências antes de retornar uma sessão nova. Seed/state do RNG são strings
decimais para preservar 64 bits no JSON. `SaveStore` escreve temporário e mantém `.bak`
do save anterior. Versões desconhecidas são rejeitadas; migrações só surgirão com v2.
`Main` troca a sessão apenas após sucesso; nova partida descarta os modelos anteriores.

Elevadores atendem o passageiro embarcado mais antigo, depois a chamada mais antiga.
Fila FIFO é determinística; o despacho ainda não é uma otimização coletiva de direção.
Cada poço atende todos os andares e impede construção na mesma coluna.
