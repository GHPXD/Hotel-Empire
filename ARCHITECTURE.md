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

`SessionSnapshot` v4 define campos explicitamente e valida tipos, limites, geometria,
catálogo e referências antes de retornar uma sessão nova. Seed/state do RNG são strings
decimais para preservar 64 bits no JSON. `SaveStore` escreve temporário e mantém `.bak`
do save anterior. Saves v1 migram para nível 1 e preferências automáticas, reconstruindo
o preço de serviços já iniciados. V1 e v2 recebem o acesso legado às quatro melhorias
N3 existentes no M3. Outras versões desconhecidas são rejeitadas.
V3 migra perfis existentes para equilibrado e inicia uso de serviços pela contagem
anterior de refeições. RNG e relógio continuam persistidos; novas chegadas usam perfis M5.
`Main` troca a sessão apenas após sucesso; nova partida descarta os modelos anteriores.

Elevadores atendem o passageiro embarcado mais antigo, depois a chamada mais antiga.
Fila FIFO é determinística; o despacho ainda não é uma otimização coletiva de direção.
Cada poço atende todos os andares e impede construção na mesma coluna.

## Gestão M3

`RoomState` guarda o nível e deriva atributos de `UpgradeDefinition` imutável.
Modificadores são absolutos em relação à definição base; o custo compra um nível.
Transporte sincroniza capacidade e velocidade sem recriar filas ou passageiros.
O preço é contratado na admissão do serviço (`agreed_price`) e preservado no save.

Preferências de equipe (`preferred_room`/`preferred_floor`) são separadas da tarefa
atual (`assignment`). Mudanças aguardam sua conclusão; postos fixos são reservados
contra atribuições automáticas. Snapshots validam capacidades efetivas, níveis,
referências e exclusividade de postos. Demolição limpa preferências obsoletas.

## Progressão M4

`HotelProgression` pertence à sessão e avalia contadores dos sistemas ao final do tick.
`ObjectiveDefinition` contém requisitos, pré-requisito e IDs de upgrades liberados;
Resources não guardam progresso. Conclusões são permanentes e ordenadas. Reputação
pode cair após uma conquista; isso não revoga o título nem os desbloqueios.

Snapshot v3 guarda IDs concluídos e acesso legado; progresso parcial vem dos contadores
já persistidos. Restore valida IDs, duplicação, ordem e autorização de salas N3 antes
de retornar a sessão. Migração avalia métricas existentes sem cobrar/pagar recompensas.
Nova sessão começa vazia. UI lê o modelo, a compra é protegida em `HotelSession`,
e o painel de objetivos não retém referência à sessão após fechá-lo ou trocar a partida.

## Conteúdo M5

`HotelCatalog` inclui seis `RoomDefinition` e três `GuestArchetype`. O perfil é escolhido
pelo RNG da sessão ao nascer; `ActorState` guarda seu ID, dinheiro corrente e contadores.
Recursos definem orçamento inicial, pesos de utilidade, ritmo de entretenimento,
duração de estadia e paciência de atendimento. Transporte mantém sua penalidade de
espera comum. `GuestSystem` aplica uma regra genérica por necessidade; serviço de lazer
nunca incrementa refeições. `service_uses` inclui todos os serviços pagos, sem hospedagem.

`HotelModel` compartilha a mesma instância de `HotelProgression` da sessão e verifica
`required_objective` antes de construir, inclusive no preview e na validação de saves.
O acesso legado a upgrades não desbloqueia café/lazer. Novas salas são N1 nesta etapa.

`HotelEvents.state` deriva evento e tempo restante de ticks inteiros, do intervalo em
`SimulationRules` e de `EventDefinition`. Não há segundo relógio nem RNG de eventos.
O multiplicador modifica o consumo do temporizador de chegadas, sem contornar hotel
fechado ou limite de hóspedes. Pausa funciona porque não avança ticks. Salvar o tick
preserva a fase do calendário; a interface apenas apresenta esse estado.
