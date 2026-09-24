# Poses de espera dos hóspedes

Geradas em 24/09/2026 diretamente no chat com `image_gen` integrado, usando as
sprites de caminhada como referência de identidade. Prompts completos em
`guest-waiting-prompts.json`.

- `balanced-waiting.png`: hóspede casual, casaco mostarda e bolsa de couro.
- `business-waiting.png`: executiva, blazer verde e pasta.
- `leisure-waiting.png`: turista, chapéu de palha e roupa lilás/creme.

Cada PNG RGBA tem 1774 × 887 pixels e quatro poses. Os arquivos originais da
geração foram preservados sem retoque. Os recortes usam a silhueta com alpha
acima de 16 e margem de quatro pixels para evitar que ruído quase transparente
nas margens determine a escala. O topo e a base dos recortes são comuns por
personagem. Coordenadas em `assets/art/characters/waiting-regions.json`.

HotelArt seleciona estas sequências nos estados `checkin`, `service_queue` e
`lift_queue`. Cada pose dura 12 ticks; o ciclo pausa junto com a simulação.
Caminhar volta a selecionar a sequência original. Mipmaps habilitados.

Validação: `tests/ui_art.gd`, zero falhas; transparência real, limites de cada
recorte, ciclo de 48 ticks, retorno à caminhada e ausência de mutação da
simulação ao renderizar. Capturas verificadas no cenário. O Godot emitiu aviso
do repositório de certificados do Windows; a suíte terminou normalmente.

Assets integrados ao projeto fonte. O ZIP Windows anterior ainda não contém
este lote. As poses são gestos discretos, sem interpolação entre desenhos.
