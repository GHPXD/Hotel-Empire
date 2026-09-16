# Hotel Empire

Tycoon 2D original em Godot **4.7.2**, GDScript tipado, renderer Compatibility.
Estado: M0 e M1a validados. Construção jogável; simulação operacional em desenvolvimento.

Abra `project.godot` no Godot e execute F6 na cena principal ou F5 no projeto.
Teste: `godot --headless --path . --script res://tests/foundation_test.gd`.
Importe antes de testar em checkout novo: `godot --headless --editor --path . --quit`.

Construção: selecione sala na lateral e clique no grid. Recepção somente no térreo.
Novo andar custa $750; poços ocupam todos os andares. Esc/clique direito cancela.
Scroll ajusta zoom; botão central arrasta a câmera. Clique numa sala para inspecionar
e use Demolir para removê-la, sem reembolso. Não há hóspedes nesta etapa.

Consulte [ROADMAP.md](ROADMAP.md), [ARCHITECTURE.md](ARCHITECTURE.md) e
[visão permanente](docs/PRODUCT_VISION.md). Os gráficos iniciais serão placeholders originais.
