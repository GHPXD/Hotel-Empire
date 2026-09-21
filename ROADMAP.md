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
- [x] M7 Art & Animation: 15 PNGs originais, caminhada e efeitos sonoros.
- [x] M8 Optimization: perfis 100/250/500/1000 agentes e operação até o limite atual de 120.
  - [x] M8a perfil inicial, descarte de render fora da câmera e equivalência visual.
  - [x] M8b admissão/saídas otimizadas; perfil integrado contínuo com 118–120 hóspedes.
- [ ] M9 QA: regressões, cenários e balanceamento.
  - [x] Confirmação/cancelamento de novo hotel e preservação do save pela interface.
- [ ] M10 Release Preparation: exports, compatibilidade e distribuição.

Uma caixa só é marcada após execução e validação. Publicação será decidida depois.

Próximo incremento: M9, QA de cenários, continuidade longa e balanceamento.
M6 não conclui suporte integral a teclado/controller, leitores de tela ou touch.
M8 mede render isolado, transporte e sobrecarga até 1000; operação integrada
contínua respeita o limite atual de 120. Não comprova 1000 hóspedes atendidos
simultaneamente a 60 FPS. Ampliar esse limite requer conteúdo/capacidade e novo perfil.
