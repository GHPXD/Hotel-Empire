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
- [ ] M5 Content Expansion: novos serviços, perfis e eventos.
- [ ] M6 UI/UX Polish: filtros, analytics, acessibilidade.
- [ ] M7 Art & Animation: substituir placeholders, áudio original.
- [ ] M8 Optimization: perfis 100/250/500/1000 agentes.
- [ ] M9 QA: regressões, cenários e balanceamento.
- [ ] M10 Release Preparation: exports, compatibilidade e distribuição.

Uma caixa só é marcada após execução e validação. Publicação será decidida depois.

Próximo incremento: M5, novos serviços, perfis de hóspedes e eventos.
M2 mediu transporte isolado até 1000 agentes e burst integrado;
isso não conclui M8 nem comprova 1000 hóspedes simultâneos sustentados com render a 60 FPS.
