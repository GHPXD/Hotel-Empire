# Revisão da M9 — protótipo desktop atual

Escopo: revisão do vertical slice e dos incrementos M0–M8 no Godot 4.7.2 deste
Windows. Não é certificação comercial, teste de todos os dispositivos ou prova de
1000 hóspedes atendidos. Export e compatibilidade do pacote pertencem à M10.

Em 21/09/2026, `tools/test.ps1 -Stress -Visual -Soak` concluiu com exit 0:
21 suítes, sem falhas, erros de script ou avisos de recursos vazados. Resumos
extraídos dos logs reais estão em `regression.json`. M9 concluída neste escopo;
o objetivo geral de evolução do jogo permanece em andamento.

| Requisito do protótipo | Evidência executável |
|---|---|
| Abrir, iniciar novo hotel, confirmar/cancelar e reiniciar estado | ui_smoke, ui_new_game |
| Construir, demolir, selecionar e expandir andares | construction_test, ui_smoke, ui_management |
| Receber hóspedes, quartos, alimentação, elevadores e limpeza | simulation_test, stress_test, long_run_test |
| Contratar/atribuir funcionários e melhorar instalações | management_test, ui_management |
| Ganhar/gastar, reconciliar caixa e operar com orçamento inicial | foundation_test, analytics_test, long_run_test, perfis management/checkin |
| Satisfação, filas e congestionamento visíveis | analytics_test, ui_operations, métricas dos perfis |
| Salvar, carregar, continuar e preservar o save ao criar novo hotel | save_test, save_multiseed_test, ui_resume, ui_new_game, long_run_test |
| Conteúdo, objetivos, perfis e eventos | progression_test, content_test, ui_progression, ui_content |
| Arte, áudio, animação e câmera | ui_art, ui_culling |
| Otimização preserva comportamento | admission_equivalence_test; perfis M8 separados |

Save_test cobre arquivo ausente/truncado, versão/conteúdo/tipo inválidos, referência
pendente e sobreposição; valida viagem de elevador, substituição com backup e
continuidade. O teste longo repete 30 checkpoints de save/load. Isso não prova
resistência a toda falha de disco/energia nem tratamento de todo erro pela UI.

Diagnóstico econômico: 12 partidas de comparação e 15 de intervenções isoladas,
três seeds por política, sem alterar regras ou injetar caixa. Há escolhas eficazes
de gestão, com limpeza limitando o hotel de referência. Espera alta não foi ocultada
nem o contrato relaxado para atingir reputação artificialmente.

Limites aceitos para esta etapa: entrada principal desktop; cobertura parcial de
teclado, sem certificação de controller/touch/leitor de tela; hóspedes ainda sem
poses dedicadas para dormir/sentar; sem música ambiente; operação contínua medida
até o limite atual de 120 hóspedes. Os testes não substituem avaliação humana de
diversão, acessibilidade ou balanceamento em muitos mapas. Esses limites permanecem
visíveis no roadmap e documentação de arte/desempenho.
