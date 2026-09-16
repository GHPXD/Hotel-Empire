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
