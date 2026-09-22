# M7 — arte raster, animação e áudio

Hotel jardim acolhedor: carvalho, painéis jade, latão e reboco creme; tecidos azuis,
terracota e violeta distinguem serviços. Interiores frontais com pista para circulação.
Arte original gerada pelo image_gen integrado; prompts e referências em `docs/art/`.

## Entrega
- Cinco interiores: recepção, quarto, bistrô, café e sala de lazer.
- Elevador dividido em poço repetido por andar e cabine móvel.
- Corredor modular, cidade ao fundo e passeio/jardim no primeiro plano.
- Cinco personagens: hóspedes equilibrado, negócios e lazer, recepcionista e limpeza.
  Cada um tem PNG transparente com quatro poses de caminhada.
- Duas faixas adicionais de trabalho: limpeza com esfregão e atendimento com
  prancheta, quatro poses cada. Originais RGBA preservados, gerados no chat pelo
  image_gen integrado; prompts em `art/staff-actions-prompts.json` e recortes em
  `assets/art/characters/action-regions.json`.
- Miniaturas do catálogo reaproveitam a arte da instalação correspondente.
- Três efeitos WAV sintetizados por `tools/generate_audio.py`: construção, melhoria
  e objetivo. Botão Som com preferência em `user://audio.cfg`.

## Contrato de apresentação
Grade: célula 62 px, andar 108 px, zoom 0,35–1,8. Interiores ajustados ao retângulo da
sala. PNGs fonte preservados; mipmaps e filtro linear melhoram redução. Textos, foco,
seleção, preview e avisos são nativos para manter informação dinâmica legível.

As faixas geradas não obedeceram perfeitamente à divisão em células iguais.
Recortes medidos pela extensão do alpha >100, com margem de 3 px, sem alterar PNGs.
Coordenadas em `characters/regions.json` e HotelArt.REGIONS. Escala comum por
personagem (altura máxima 46 px) e âncora central inferior mantêm os pés no chão.
Nunca presumir que uma faixa nova usa os mesmos recortes.

Caminhada: quatro frames a 10 quadros/s na velocidade normal, derivados do tick,
com fase por ID. Espelhamento segue destino horizontal. Parado usa pose 1; pausa
congela animação. Cabine acompanha posição autoritativa. Não há RNG, nós por ator
ou estado visual no save. Não há mudanças de economia ou gameplay.
Os estados `cleaning` e `working` selecionam as faixas próprias dos funcionários,
com troca de pose a cada quatro ticks (2,5 fps). Caminhada e espera mantêm a faixa
original. O atendimento representa trabalho administrativo durante a atribuição,
mesmo sem um hóspede presente. A geração tem pequenas variações entre poses;
não equivale a uma animação produzida com rig esquelético.

## Limites
Sem poses dedicadas para sentar ou dormir: hóspedes parados usam uma pose da
faixa. Quartos, recepções e restaurante têm pinturas próprias para níveis 2 e 3;
upgrades de elevador ainda usam a pintura base com nível textual. Sem música ou ambiente
contínuo nesta entrega. Novos conteúdos precisam de arte própria. M8 ainda deve
medir custo de render/VRAM em grandes hotéis; esta entrega não comprova 1000 agentes
renderizados a 60 FPS.

## Verificação
`ui_art.gd`: carregamento, alpha, limites dos recortes, ciclo, zoom mínimo/normal/máximo,
ausência de mutação da partida e persistência de Som. Capturas:
`.runtime/m7-art-0.35.png`, `m7-art-0.90.png`, `m7-art-1.80.png`.
Demais suítes cobrem construção, seleção, bloqueios, filas, save/load, foco,
texto ampliado e retomada com novo render.

Extensão de funcionários (21/09/2026): catálogo válido pelo gda; `ui_art` e
`ui_culling` passaram sem falhas, incluindo nove combinações de câmera com as
ações novas. Verificados alpha, limites, ciclo, retorno à faixa original e ausência
de mutação do snapshot. Captura inspecionada: `art/hotel-staff-actions.png`.

Extensão de ambientes (22/09/2026): `bedroom-level-2.png` e
`reception-level-2.png` gerados pelo image_gen integrado no chat. Prompts em
`art/room-upgrades-prompts.json`; dimensões e SHA-256 em `art/manifest.json`.
HotelView escolhe a textura a partir do nível persistido da sala. A compra e os
efeitos econômicos continuam na lógica existente. O catálogo de construção mantém
a imagem do nível 1. A vitrine `ui_art` compra melhorias reais para mostrar quartos
base e melhorados juntos, além da recepção melhorada, nos três níveis de zoom.
Validação: `tools/test.ps1 -Visual` passou nas 22 suítes do worktree em 22/09/2026.
Após ativar mipmaps nos dois imports, `ui_art` passou novamente; captura de zoom
0,90 inspecionada. Incluída no ZIP Windows da revisão `ce2ff22`; seis casos do
pacote extraído aprovados em `release/upgrade-diagnostics-matrix.json`.

Extensão do restaurante (22/09/2026): pinturas distintas para níveis 2 e 3,
com mesas e iluminação progressivamente refinadas. Prompts em
`art/restaurant-upgrades-prompts.json`, PNGs preservados e hashes no manifesto.
O catálogo mantém a pintura base; a sala usa seu nível persistido para escolher
a textura. Café e lounge não têm upgrades definidos atualmente. A vitrine compra
os dois níveis de restaurante no andar superior e mantém o nível 1 no térreo.
Importação com mipmaps e `ui_art` validados; três zooms, compras reais e snapshot
inalterado. Incluída no ZIP da revisão `80d51de`, com compra, save/load e seleção
da pintura verificados no executável nas seis combinações de janela/texto.

Extensão N3 de quarto/recepção (22/09/2026): cama com dossel e balcão de mármore
distinguem os níveis máximos. PNGs gerados pelo image_gen integrado, preservados
com mipmaps; prompts em `art/final-room-upgrades-prompts.json`. A vitrine compra
os upgrades reais e coloca quartos N1/N2/N3 lado a lado. Essas duas pinturas novas
ainda não estão no pacote Windows da revisão `80d51de`.
`ui_art` passou sem falhas com compras e capturas nos três zooms; captura 0,90
inspecionada. O snapshot da simulação permanece inalterado durante a renderização.
