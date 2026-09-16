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

## M1b–c — simulação operacional
- `simulation_test.gd` strict: zero falhas/diagnósticos. Hóspede fez check-in,
  dormiu, consumiu 3 refeições, saiu; receita $224, um quarto limpo e 7 entregas
  de elevador (hóspede + funcionário). Salários/manutenção efetivamente cobrados.
- Sem recepcionista: hóspede abandona após esgotar paciência.
- 13 passageiros isolados: capacidade nunca excedeu 4, todos chegaram ao destino,
  entrega exatamente uma vez, fila drenada e espera medida.
- Validação agregada de 21 scripts e boot integrado sem diagnósticos.
- UI smoke ampliado: contratar ambos funcionários, abrir hotel, gerar receita,
  pausar. Zero falhas. Largura estável do botão de chegadas evita deslocar a pausa.
- Conteúdo de simulação segue provisório; métricas acima demonstram funcionamento,
  não balanceamento final. Multi-seeds/stress e save/load aguardam próximo marco.

## M1d — persistência e aceite do slice
- `tools/test.ps1 -Visual` passou integralmente: foundation, construction (16 checks),
  simulation, save, ui_smoke e ui_resume. Logs em `.runtime/`; runner rejeita erros
  de script, erros de engine e vazamento de objetos, além de exit code não zero.
- Save test: gravação/backup, ida e volta completa, viagem de elevador em curso,
  continuidade idêntica por 2.400 ticks; rejeição de versão desconhecida, catálogo
  inexistente, tipo inválido, overlap, passageiro inexistente, arquivo truncado/ausente.
- Corrigidos dois defeitos descobertos pelo teste: lambda em signal retinha sessão;
  substituída por método ligado. Relógio acumulava floats; agora deriva de tick inteiro.
- Fluxo gráfico: construir quatro tipos em dois andares, contratar, abrir chegadas,
  gerar receita, pausar, salvar, zerar sessão, carregar estado idêntico, zoom, pan e F3.
- Processo gráfico independente carregou o save e avançou 71 ticks sem erros.
- Capturas inspecionadas em 1280×800 e 1024×640. O comando solicitou 1024×720,
  mas o viewport capturado manteve proporção 16:10; não declarar 1024×720 validado.
  Sidebar tem rolagem e controles utilizados permaneceram acessíveis.
- Não validados ainda: navegação integral por teclado/controller, touch, leitores de
  tela, DPI variados, exports, stress 500–1000 agentes e balanceamento multi-seed.
  Essas limitações não são apresentadas como features prontas.
