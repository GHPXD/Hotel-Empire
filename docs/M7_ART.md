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
faixa. Upgrades usam a mesma pintura com nível textual. Sem música ou ambiente
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
