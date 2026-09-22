# Roadmap

O pedido operacional atual organiza o trabalho abaixo; a visão permanente em
`docs/PRODUCT_VISION.md` permanece como destino do produto, sem exigir conteúdo antecipado.

- [x] M0 Foundation: projeto, dados, economia, fila, testes, boot validado.
- [x] M1 Vertical Slice: construção, câmera, hóspedes, serviços, transporte, funcionários,
  satisfação, save/load, HUD, debug e ciclo integrado validado.
  - [x] M1a construção/andares/seleção/demolição.
  - [x] M1b hóspedes/check-in/decisão/serviços/economia.
  - [x] M1c elevadores/filas/funcionários/limpeza/reputação.
  - [x] M1d save/load/UI/diagnóstico/QA integrado.
- [x] M2 Simulation Core: robustez, stress, métricas e múltiplas seeds.
- [x] M3 Hotel Management: upgrades, atribuições e finanças.
- [x] M4 Progression: desbloqueios e objetivos.
- [x] M5 Content Expansion: novos serviços, perfis e eventos.
- [x] M6 UI/UX Polish: filtros, analytics e melhorias de leitura/foco no desktop.
  - [x] Causa atual da fila de check-in e ação sugerida no inspetor e em Operação.
- [x] M7 Art & Animation: 21 PNGs originais, caminhada, ações de funcionários e efeitos sonoros.
  - [x] Pinturas dedicadas para quartos e recepções a partir do nível 2.
- [x] M8 Optimization: perfis 100/250/500/1000 agentes e operação até o limite atual de 120.
  - [x] M8a perfil inicial, descarte de render fora da câmera e equivalência visual.
  - [x] M8b admissão/saídas otimizadas; perfil integrado contínuo com 118–120 hóspedes.
- [x] M9 QA: regressões, cenários e diagnóstico de balanceamento do protótipo desktop.
  - [x] Confirmação/cancelamento de novo hotel e preservação do save pela interface.
  - [x] Seis cenários de 30 dias com orçamento inicial e continuidade de save/load.
  - [x] Comparação de quatro decisões de gestão em três seeds, 30 dias e orçamento real.
  - [x] Diagnóstico do check-in: 15 cenários isolando limpeza, quartos, recepção e elevador.
  - [x] Revisão final de QA e bateria conjunta de 21 suítes, sem falhas.
- [ ] M10 Release Preparation: exports, compatibilidade e distribuição.
  - [x] Preset Windows, build reproduzível, ZIP, licenças e manifesto de hash/revisão.
  - [x] Boot e operação/save/load pela interface no executável, inclusive ZIP extraído em caminho com espaços.
  - [x] Matriz local de seis combinações de janela/texto, inventário do ZIP e hash do executável.
  - [x] Saída com salvar/descartar/cancelar, pausa modal e proteção contra falha de gravação.
  - [x] Ajuda F1 no jogo: primeiros passos, diagnóstico de filas, controles e saves, com pausa e rolagem.
  - [x] Recuperação de backup validado pela interface, com confirmação e preservação dos arquivos.
  - [ ] Revisão final de distribuição e compatibilidade externa documentada.

Uma caixa só é marcada após execução e validação. Publicação será decidida depois.

Próximo incremento: M10, export local, validação do pacote e documentação de distribuição.
M6 não conclui suporte integral a teclado/controller, leitores de tela ou touch.
M8 mede render isolado, transporte e sobrecarga até 1000; operação integrada
contínua respeita o limite atual de 120. Não comprova 1000 hóspedes atendidos
simultaneamente a 60 FPS. Ampliar esse limite requer conteúdo/capacidade e novo perfil.
