# Plano de testes

Automatizados: economia (saldo, investimento, resultado), filas (limite, FIFO,
duplicação), construção (limites, sobreposição, custo, suporte, demolição),
transporte (capacidade, embarque, destinos), ciclo do hóspede, limpeza e save/load.
Testes de save devem cobrir arquivos ausentes, truncados, versão desconhecida e
referências inválidas, preservando a sessão atual em caso de falha.

Integração: construir → contratar → check-in → quarto → fome → refeição → elevador
→ saída → receita → limpeza → nova reserva. Salvar no meio, carregar e continuar.

QA visual: 1440×900 e 1024×720, pan/zoom, preview válido/inválido, cancelamento,
inspeção, foco por teclado, pausa/velocidade, alertas de filas. Plataformas móveis e
Web não são declaradas testadas antes de exports reais.

Evidências de cada marco serão registradas em `docs/VALIDATION.md`.

Runner Windows: `powershell -File tools/test.ps1 -Visual`. Remove-se `-Visual` para
somente os testes headless. Os testes gráficos usam `Viewport.push_input` com
coordenadas locais, não invocação direta dos callbacks dos botões de gameplay.
O teste de nova sessão usa a API interna de troca; diálogo de confirmação ainda
precisa de cobertura dedicada. Save/load também tem teste em outro processo.

`-Stress` adiciona continuidade em 20 checkpoints/5 seeds e verificações de conservação
de agentes, reconciliação do caixa, capacidade, geometria, referências, ocupação e
snapshots periódicos. Transporte isolado deve entregar exatamente uma vez cada agente
e drenar as filas para 100/250/500/1000 passageiros. Resultados de tempo são informativos,
sem limiar dependente da máquina; FPS renderizado continua no plano de M8.

M3: `management_test.gd` cobre custos/limites de upgrades, atributos efetivos,
manutenção, contrato de preço, atribuições durante limpeza/viagem, reserva de postos,
demolição, migração de save M2 real e continuidade. Compara check-in e transporte
antes/depois. `ui_management.gd` compra upgrade por mouse, abre Equipe, seleciona
funcionário/andar pelo teclado e aplica; confere custos fixos em Finanças.
PopupMenus recebem `Input.parse_input_event` com window_id; demais controles usam
`Viewport.push_input`. Capturas são inspecionadas; isso não cobre todo o teclado/controller.

M4: `progression_test.gd` testa limites exatos, combinação de requisitos, persistência
da conquista após queda de reputação, compra bloqueada sem efeitos, reset de partida,
continuidade após load, dados inválidos e migração de fixtures reais v1/v2. Vinte e cinco
hóspedes sequenciais em hotel pequeno com caixa inicial normal verificam viabilidade.
Stress exige os dois desbloqueios N3 em até cinco dias no template padrão/5 seeds.
`ui_progression.gd` testa bloqueio visível, painel vivo, Esc, compra liberada, save/load
pela toolbar e fechamento/reset do painel ao trocar sessão. Captura topo e fim da rolagem.

M5: `content_test.gd` verifica construção bloqueada, exceção legada restrita a N3,
escolhas diferentes de perfis na mesma situação, refeição versus lanche com fome alta,
saldo, alívio, caixa, filas/capacidade e uso em três seeds de operação controlada.
Valida fronteiras de eventos, efeito real nas chegadas, hotel fechado e continuidade
atravessando fim e início de eventos. Fixture M4/v3 migra sem mutação; perfis e
contadores inválidos são rejeitados. `ui_content.gd` testa construção pelo viewport,
inspeção de hóspede, calendário pausado e save/load com evento ativo pela toolbar.

M6: `analytics_test.gd` verifica hotel vazio, ocupação/limpeza, média dos hóspedes
presentes, filas separadas, custos reconciliados, filtros combinados, elevador por
andar, ordenação estável e ausência de mutação. Preferência de texto tem roundtrip
separado e fallback para valor inválido.
`ui_operations.gd` digita busca com/sem resultados, opera filtros pelo teclado,
inspeciona com Enter, confirma centralização, atualiza lista quando a situação muda,
fecha com Esc e verifica retorno de foco. F4 amplia texto, persiste preferência sem
alterar snapshot e a mantém ao trocar partida, resetando filtros. Equipe e Finanças
também abrem/fecham pelo teclado. Capturas normais/ampliadas e janela menor são inspecionadas.


M7: `ui_art.gd` monta todos os ambientes e cinco personagens, verifica alpha real,
recortes dentro das texturas, avanço/loop da caminhada, render em zoom 0,35/0,9/1,8
sem mutação da sessão e botão Som com persistência. WAVs devem carregar com duração
válida. Capturas são inspecionadas no jogo. Bateria completa: 17 suítes com Stress/Visual.
