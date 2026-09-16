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
