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
