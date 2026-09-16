# Evidências de validação

## M0 — 2026-09-16
- Godot 4.7.2 real; importação registrou classes globais.
- `gda script run res://tests/foundation_test.gd --strict`: exit 0, zero falhas,
  zero diagnósticos, nenhuma fuga de objetos detectada.
- `gda scene preflight res://core/game/main.tscn`: `started=true`, `status=ready`,
  diagnósticos vazios.
- Primeira validação antes da importação não resolveu class_name; resolvido pelo
  scan do editor (passo obrigatório em checkout limpo).
- Sandbox impediu probe de escrita do gda e configurações do editor; testes
  subsequentes executados com permissão de processo e user-data-root local.
- Boot gráfico e gameplay ainda pendentes: M0 contém apenas a cena de fundação.

## M1a — construção
- 15 checks de construção passaram: overlap, limites, suporte, recepção no térreo,
  poços em todos os andares, expansão, custos e bloqueio de demolição ocupada.
- Todos os 11 scripts então existentes compilaram; fundação passou novamente.
- Cena integrada: preflight ready, zero diagnósticos.
- QA gráfico real em OpenGL/AMD: `tests/ui_smoke.gd` acionou botões e grid por
  eventos de mouse, construiu quatro tipos em dois andares, rejeitou overlap e
  cancelou construção. Zero falhas; captura inspecionada em `.runtime/construction-ui.png`.
- Corrigido o harness de QA: `push_input(..., true)` para coordenadas locais sob
  stretch. O primeiro teste usava coordenadas locais como coordenadas de janela.
- Captura 1280×800 legível, sem recorte de comandos. Outras resoluções, zoom/pan
  e teclado completo ainda precisam de cobertura adicional no M1d.
