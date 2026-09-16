# Hotel Empire

Tycoon 2D original em Godot **4.7.2**, GDScript tipado, renderer Compatibility.
Estado: **M0 + M1 vertical slice jogável**, validados. Protótipo, ainda sem arte final
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
Novo hotel pede confirmação e preserva o arquivo salvo. Finanças exibe o extrato.

Sugestão inicial: recepção e bistrô no térreo, elevador em coluna livre, outro andar
com vários quartos. Contrate os dois tipos de funcionário antes de abrir chegadas.
Poucos quartos criam fila na recepção; expansão excessiva pressiona transporte e limpeza.

No Windows deste ambiente: `powershell -File tools/test.ps1 -Visual` executa import,
quatro suítes headless e dois testes gráficos. Passe `-GodotPath` para outro engine.
Testes isolam dados em `.runtime/`; não sobrescrevem seu save normal.

Teste integrado: `godot --headless --path . --script res://tests/simulation_test.gd`.

Limitações atuais: placeholders procedurais, atribuição automática de equipe, uma
categoria de hóspede, sem áudio/upgrades/progressão e sem export validado. Stress e
balanceamento multi-seed são o próximo marco. UI desktop testada; mobile/Web futuros.

Consulte [ROADMAP.md](ROADMAP.md), [ARCHITECTURE.md](ARCHITECTURE.md) e
[visão permanente](docs/PRODUCT_VISION.md). Os gráficos iniciais serão placeholders originais.
