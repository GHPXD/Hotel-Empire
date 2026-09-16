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

## M2 — simulação, stress e correção de continuidade
- Runner completo `tools/test.ps1 -Stress -Visual`: oito suítes passaram sem erro/leak.
  Métricas de filas foram acrescentadas depois e `stress_test.gd --strict` passou novamente.
- Nova suíte de saves encontrou 7 divergências em 20 checkpoints antes da correção.
  Primeiro desvio reproduzido: seed 1, tick 1012, elevador em 1.07 versus 1.0.
  Causa: resíduo positivo no door_timer após JSON alterava a transição de estado.
  Comparações de limites usam TIME_EPSILON=1e-8, menor que 1/1.000.000 do tick.
- Após correção: 20 checkpoints passaram, cobrindo working/idle/walking/checkin/riding/
  using/lift_queue/cleaning. Cada um continuou 600 ticks comparando todos os campos.
  Estados/contagens iguais; somente floats admitem erro absoluto <=1e-8. O teste de
  disco inicialmente comparava texto JSON e detectou diferença de arredondamento em
  atributos de atores; agora compara campos com o mesmo critério explícito.
- Cinco seeds de 5 dias: zero falhas de invariantes e ciclo produtivo em todas.
- 100/250/500/1000 agentes no transporte: entrega de todos exatamente uma vez, destinos
  corretos, capacidade respeitada e filas drenadas. Máximo observado com 1000: 3,599 ms
  por passo do transporte, sem renderização. Não extrapolar para jogo inteiro.
- CLI real: cenário padrão 30 dias, 36.000 ticks, 374 reservas, 488 saídas e 930 viagens;
  tower burst 1000: 20 andares, 1000 saídas, apenas 24 reservas. Zero falhas nos dois.
- Tempos e resultados completos preservados em `docs/benchmarks/`. Sem ajustes arbitrários
  de custos/preços: esta etapa mede e corrige comportamento, não declara economia final.

## M3 — upgrades, equipe e finanças
- `tools/test.ps1 -Stress -Visual`: dez suítes aprovadas, sem erros/leaks do engine.
- Upgrades dos quatro tipos até N3: custo exato, manutenção efetiva, limite e saldo
  insuficiente; Resources base permanecem imutáveis. Save/load preserva níveis.
- Serviço iniciado mantém preço contratado mesmo após upgrade e save/load;
  novos hóspedes sem saldo para o preço atualizado escolhem novamente.
- Equipe: mudança de recepção, exclusividade/reserva de posto, mudança de andar
  durante limpeza e viagem, retorno ao automático e limpeza de referência ao demolir.
- Fixture real M2 (`tests/fixtures/m2-save-v1.json`) migra sem alterar a entrada,
  continua 600 ticks e salva em v2. Níveis inválidos são rejeitados.
- Check-in ficou mais rápido; transporte de 20 passageiros passou de 279 para 125
  ticks com elevador N3 no cenário isolado. Não equivale a retorno econômico validado.
- Teste gráfico compra upgrade pelo mouse, seleciona camareiro/andar pelo teclado,
  aplica preferência e abre Finanças para conferir custos fixos. PopupMenus recebem
  eventos via Input com window_id; controles normais recebem eventos do viewport.
- Teste gráfico adicional com resolução solicitada 1024×720 aprovado; capturas reais
  1024×640 inspecionadas, incluindo rolagem do inspetor e painel Equipe. Capturas locais:
  `.runtime/m3-staff.png` e `.runtime/m3-upgrade.png`.
- Economia segue como hipótese de protótipo; contrato e próximo experimento em
  `docs/M3_BALANCE.md`. Navegação integral por teclado/controller permanece pendente.

## M4 — objetivos e desbloqueios
- Runner completo `tools/test.ps1 -Stress -Visual`: doze suítes passaram, sem erros
  ou leaks reportados pelo engine. Novas classes exigiram import antes do primeiro teste.
- Três objetivos com fronteiras exatas, múltiplos requisitos, bloqueio transacional
  de compra, permanência após queda de reputação e reset em nova sessão verificados.
- Snapshots v3 preservam progresso parcial/concluído; rejeitam IDs desconhecidos,
  duplicados, sequência inválida, flags malformadas e N3 instalado sem autorização.
- Fixtures reais M2/v1 e M3/v2 migram; v2 continua 600 ticks e salva em v3. Migração
  não modifica o dicionário de entrada e mantém acesso legado às melhorias N3 do M3.
- Hotel de dois quartos, caixa inicial $12.000, seed 99: 25 visitas sequenciais
  concluíram os três objetivos; caixa final $8.972. Continuidade de 600 ticks após
  save/load sem divergência. Não representa comportamento ou ritmo de jogadores reais.
- Cinco seeds do template padrão liberaram N3 entre ticks 1661–1795; quatro também
  conquistaram o título nos cinco dias. Evidência: `benchmarks/m4-progression.json`.
- UI: N2 comprado por mouse, motivo do bloqueio N3, painel que atualiza aberto,
  fechamento por Esc, compra após desbloquear, salvar/carregar pela toolbar e reset
  ao trocar partida. Capturas topo/fim da rolagem inspecionadas.
- Resolução padrão e teste adicional solicitado em 1024×720 passaram; captura menor
  efetiva 1024×640. Arquivos locais `.runtime/m4-locked.png`, `m4-objectives.png` e
  `m4-objectives-bottom.png`. Nenhuma declaração de QA integral de acessibilidade.
