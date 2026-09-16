# Progressão M4

## Contrato de protótipo

Para um hotel já construído no template padrão, sem upgrades, com chegadas contínuas,
os dois objetivos que liberam N3 devem ser alcançáveis em até cinco dias simulados nas
cinco seeds de regressão. Para uma operação pequena com o caixa inicial de $12.000,
25 visitas sequenciais devem permitir completar os três objetivos sem aporte de caixa.
Não é uma meta de duração para iniciantes: os cenários não medem tempo de construção,
decisão, entendimento da interface ou ritmo de jogadores reais.

Proteções: nenhuma compra bloqueada desconta caixa; nenhuma conclusão paga bônus;
quedas posteriores de reputação não revogam conquistas; nova partida reseta progresso;
carregamento não repete efeitos nem bloqueia instalações previamente liberadas.

## Dados e regras

Fonte única dos requisitos: `data/progression/*.tres`, lida por `HotelProgression`.
Cada objetivo requer o anterior. Os contadores são acumulados na partida, sem reset
entre objetivos; todos os requisitos de um objetivo precisam valer no mesmo tick.

| Objetivo | Requisitos | Recompensa |
| --- | --- | --- |
| Primeiras estadias | 3 reservas | Compra de quarto/recepção N3 |
| Operação completa | 10 reservas, 5 refeições, 5 limpezas | Compra de bistrô/elevador N3 |
| Hotel de referência | 20 visitas concluídas, reputação ≥65 | Título, sem efeito econômico |

Reservas, refeições e visitas são contadores inteiros de `GuestSystem`; limpeza é
contador inteiro de `EmployeeSystem`; reputação é o valor corrente 0–100 do sistema
de hóspedes. A interface mostra reputação com uma decimal; a comparação usa o valor
real. Visitas concluídas incluem visitantes que foram embora sem reservar, conforme
a métrica existente. As etapas anteriores ainda exigem operação de hospedagem real.

Recursos básicos e N2 não exigem objetivo. Liberar N3 não compra automaticamente:
custos e manutenção do M3 continuam iguais. Objetivos não alteram taxa de chegadas,
RNG, preço ou satisfação. Saves v1/v2 recebem acesso às quatro melhorias N3 do M3;
o painel explica essa exceção. Os objetivos ainda podem ser conquistados normalmente.

## Evidências e limites

`tools/test.ps1 -Stress -Visual` passou nas doze suítes. Limites exatos, requisitos
incompletos, reset, estados inválidos, migração real v1/v2, save/load com 600 ticks
de continuidade, interface e janela menor foram verificados.

No template padrão (12 quartos, dois recepcionistas, dois camareiros, $250.000 de
caixa inicial), seeds 1/17/123/555/9001 liberaram todo N3 entre ticks 1661 e 1795:
166,1–179,5 segundos de simulação, ou 1,38–1,50 dias de 120 segundos. O título final
foi alcançado por quatro seeds nos cinco dias; seed 555 não atingiu seus requisitos
simultaneamente. A conquista permanece após eventual queda de reputação.

No hotel pequeno (dois quartos, uma recepção, um bistrô, um elevador, um funcionário
de cada função), seed 99, as 25 visitas sequenciais produziram 25 reservas, 66 refeições
e 25 limpezas. Ao fim da verificação, incluindo 600 ticks de continuidade: 29.124 ticks,
caixa $8.972 e reputação 98,34. Partiu de $12.000, sem subsídios ou upgrades.

As medições por seed estão em `benchmarks/m4-progression.json`. O cenário sequencial
é favorável à satisfação e não representa chegadas normais. Cinco seeds são regressão,
não confiança estatística de balanceamento. Não retunamos custos/efeitos do M3.

## Próxima decisão de balanceamento

Testar jogadores iniciantes construindo com $12.000: registrar tempo até entender o
bloqueio, abrir Objetivos, concluir cada etapa e comprar N3. Comparar expansão e
upgrade somente quando ambos estiverem disponíveis e acessíveis. Se o protótipo
deixar de cumprir as metas acima, revisar primeiro gargalos e requisitos; se jogadores
não entenderem a regra, melhorar a apresentação antes de reduzir o requisito.
Mudanças ficam versionadas em Git para reversão. Os relatórios são locais, sem coleta remota.
