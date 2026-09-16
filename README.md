# Hotel Empire

Tycoon 2D original em Godot **4.7.2**, GDScript tipado, renderer Compatibility.
Estado: **M0–M6**, validados: simulação, gestão, conteúdo inicial e interface operacional. Protótipo, ainda sem arte final
ou balanceamento de produção.

Abra `project.godot` no Godot e execute F6 na cena principal ou F5 no projeto.
Teste: `godot --headless --path . --script res://tests/foundation_test.gd`.
Importe antes de testar em checkout novo: `godot --headless --editor --path . --quit`.

Construção: selecione sala na lateral e clique no grid. Recepção somente no térreo.
Novo andar custa $750; poços ocupam todos os andares. Esc/clique direito cancela.
Scroll ajusta zoom; botão central arrasta a câmera. Clique numa sala para inspecionar
e use Demolir para removê-la, sem reembolso. Contrate recepcionista e camareiro(a),
depois abra o hotel. Hóspedes escolhem serviços, viajam e pagam; quartos usados
aguardam limpeza. Clique nos personagens para inspecionar necessidades e estado.
Pausa/1x/2x/3x controlam o tempo. Fechar chegadas permite esvaziar o hotel.
Espaço pausa/retoma; F3 mostra debug. Salvar (ou Ctrl+S) preserva a sessão em
`user://hotel-v1.json`; Carregar restaura inclusive filas e viagens em andamento.
Novo hotel pede confirmação e preserva o arquivo salvo. Finanças exibe extrato e
custos fixos diários de manutenção e salários.

Operação (F2) mostra ocupação, limpeza, filas, maior espera atual e custos do hotel.
Filtre salas por tipo, andar e situação; selecione uma e pressione Enter para
inspecionar e centralizar a câmera. Os indicadores resumem o hotel inteiro;
os filtros afetam apenas a lista, ordenada pela maior fila.

Ctrl+F leva à busca de construção, que aceita nomes com ou sem acentos; o seletor
de categoria reduz o catálogo. F4 alterna texto padrão/ampliado e salva a preferência
do dispositivo em `user://interface.cfg`, separada da partida. Tab navega controles;
Esc fecha os painéis e devolve foco ao botão de abertura. Finanças tem rolagem.

Selecione uma sala ou elevador para comparar e comprar upgrades até N3 no inspetor
(role a lateral para baixo). Equipe permite fixar recepcionistas em recepções e
camareiros em andares, ou voltar ao automático. Uma nova preferência não cancela
viagem ou limpeza em andamento. Saves usam schema v4 e migram arquivos v1/v2/v3;
o nome `hotel-v1.json` foi mantido para encontrar partidas anteriores.

Objetivos mostra requisitos e recompensas. Três reservas liberam N3 de quartos e
recepções; dez reservas, cinco refeições e cinco limpezas liberam N3 de bistrôs e
elevadores. Depois, vinte visitas concluídas e reputação 65 concedem o título
Hotel de referência. Desbloqueios são permanentes, mas upgrades continuam pagos.
N2 e construção básica são livres. Partidas anteriores mantêm o acesso a N3.

Primeiras estadias também libera o Café Brisa; Operação completa libera a Sala
Horizonte. O café atende fome rapidamente, com menor alívio que o bistrô; a sala
atende entretenimento. Esses dois serviços possuem apenas N1 neste incremento.
Hóspedes equilibrados, de negócios e de lazer variam orçamento e preferências;
clique no personagem para ver seu perfil. A localização e a demanda afetam o uso.

O calendário alterna Feira da cidade (+50% na procura) e Dias tranquilos (-35%).
Um evento começa a cada três dias simulados e dura um dia, sem sobreposição.
A faixa abaixo dos controles mostra a próxima ocorrência ou o evento ativo;
passe o mouse para ler o efeito. Pausar congela o calendário; fechar chegadas
impede visitantes novos durante eventos, mas o tempo continua correndo.

Sugestão inicial: recepção e bistrô no térreo, elevador em coluna livre, outro andar
com vários quartos. Contrate os dois tipos de funcionário antes de abrir chegadas.
Poucos quartos criam fila na recepção; expansão excessiva pressiona transporte e limpeza.

No Windows deste ambiente: `powershell -File tools/test.ps1 -Visual` executa import,
oito suítes headless e seis testes gráficos. Passe `-GodotPath` para outro engine.
Testes isolam dados em `.runtime/`; não sobrescrevem seu save normal.
Acrescente `-Stress` para cinco seeds, 20 checkpoints de save e transporte com
100/250/500/1000 agentes. Evidências: [benchmarks](docs/benchmarks/README.md).

Teste integrado: `godot --headless --path . --script res://tests/simulation_test.gd`.

Simulação sem interface:

```sh
godot --headless --path . -- --simulate --days=30 --seed=123 --template=standard --output=res://.runtime/report.json
```

Opções: `--days=1..60`, `--seed=inteiro`, `--starting-money=250000`,
`--template=standard|tower`, `--guests=0..1000`, `--output=caminho`.
Zero hóspedes significa chegadas contínuas; valor positivo cria um burst inicial
e fecha novas chegadas. O relatório distingue pico de população média. A pasta de
saída precisa existir. Templates de teste custam dinheiro e podem ser recusados.
O JSON inclui receitas, despesas, ocupação, satisfação, esperas, rotas, tempo de tick,
memória do processo, objetivos concluídos, tick de cada conquista, serviços usados,
perfis dos hóspedes ainda presentes, estado do evento e falhas.
Medidas headless não equivalem a FPS com renderização.

Limitações atuais: placeholders procedurais, sem áudio, apenas seis instalações,
três perfis e dois eventos, e sem export validado. Testes
multi-seed são regressões, não balanceamento final. UI desktop testada; mobile/Web futuros.

Consulte [ROADMAP.md](ROADMAP.md), [ARCHITECTURE.md](ARCHITECTURE.md) e
[visão permanente](docs/PRODUCT_VISION.md). Os gráficos iniciais serão placeholders originais.
