# Changelog

## 0.1.0 em desenvolvimento — 2026-09-16
- Auditoria inicial: sem projeto Godot, cenas, código de jogo ou Git.
- Preservada a visão do produto e as configurações/skills locais.
- Fundação: Godot 4.7.2 Compatibility, Resources de quatro salas, economia e FIFO.
- Plano incremental, arquitetura e critérios de validação documentados.
- M1a: construção validada, andares, poços, demolição, seleção, HUD e câmera.
- QA com entrada real no viewport e testes automatizados de construção.
- M1b–c: tick fixo, hóspedes/utility simples, atendimento, receita, despesas,
  filas, elevadores FIFO com capacidade, contratação, limpeza e reputação.
- Inspeção de agentes, diagnóstico de filas e controles de operação/tempo.
- M1d: snapshots v1, backup, validação transacional, restauração de viagens e RNG,
  novo hotel, finanças, debug F3, save Ctrl+S e pausa por Espaço.
- Corrigidos ciclo de referências, deriva do relógio, satisfação de visitantes
  recusados e seleção de elevador fora dos limites do hotel.
- Bateria completa e retomada em outro processo aprovadas.

## M2 — robustez e medição
- Comando `--simulate` com templates, seed, duração, orçamento e chegadas configuráveis;
  JSON de economia, satisfação, ocupação, filas, transporte, memória e tempo de tick.
- Cinco seeds, 20 checkpoints de save e stress isolado de 100/250/500/1000 passageiros.
- Corrigida divergência após load em limites temporais: resíduo decimal na porta do
  elevador atrasava o transporte em um tick; demais temporizadores usam a mesma tolerância.
- JSON de save utiliza precisão completa. Comparações de estado mantêm estados/contagens
  exatos e tolerância absoluta 1e-8 para resíduos de floats.
- Relatórios reproduzíveis de 30 dias e burst de 1000 hóspedes registrados em docs/benchmarks.
