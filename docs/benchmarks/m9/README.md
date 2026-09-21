# M9 — QA longo e referência econômica

## Contrato (21/09/2026)
Testar hotel pequeno com orçamento inicial real de $12.000 e procura natural.
Referência de oito quartos: caixa nunca negativo e objetivo steady_service em até
cinco dias. Configuração compacta de dois quartos serve de comparação diagnóstica,
sem exigir que ofereça o mesmo atendimento. Não alterar regras para passar testes.

Ambos têm recepção, bistrô, elevador, um recepcionista e uma pessoa de limpeza.
Dois quartos usam um andar superior; oito usam dois, com quatro por andar e sem
ocupar o poço. Não compram upgrades nem constroem serviços desbloqueados durante
o experimento. Sem injeção de dinheiro, hóspedes manuais ou alterações de paciência.

## Método
long_run_test.gd executa seis partidas: dois layouts × seeds 1, 17, 123, 30 dias
simulados cada. Checa invariantes a cada 100 ticks. A cada cinco dias (até o dia 25),
serializa para JSON, restaura e compara snapshots completos; avança original e cópia
por 120 ticks e compara novamente, passando a usar a sessão restaurada.
São 30 checkpoints de continuidade. Estados incluem calendário de eventos e RNG.
Relatório bruto em long-run.json. O teste não mede FPS nem experiência humana.

| Layout | Caixa mínimo | Caixa final | Reservas | Refeições | Reputação final |
|---|---|---|---|---|---|
| 2 quartos | 6.720 | 22.198–22.870 | 116–119 | 111–120 | 44,90–47,57 |
| 8 quartos | 2.370 | 34.832–35.112 | 226–228 | 217–219 | 48,42–53,22 |

Referência de oito quartos libera steady_service nos ticks 1924–1969 (~1,60–1,64
dias). Caixa positivo nas seis partidas; receitas/despesas conciliadas e nenhuma
divergência de continuidade. Nenhuma alteração de balanceamento foi feita.

Solvência não equivale a boa qualidade: trusted_hotel não foi obtido nesses layouts
estáticos. Não afirmar que a economia está finalizada. Próxima investigação M9:
comparar expansão, equipe, serviços e upgrades financiados pela própria partida,
com métricas de satisfação/filas, antes de ajustar parâmetros. Essa comparação foi
executada posteriormente: método e resultados em `MANAGEMENT.md`.

## Execução
`tools/test.ps1 -Soak` executa import, oito suítes básicas e long_run_test.
Acrescente -Stress -Visual para o conjunto de 21 suítes. Dados locais em .runtime;
nenhum save pessoal é lido/escrito. O relatório vai para .runtime/m9-long-run.json.

A primeira montagem do layout de oito quartos colidia com o poço, detectada pela
asserção de contagem de salas. Corrigida para colunas 0,2,4,8 e repetida a bateria.
O artefato versionado contém somente a execução corrigida, com zero falhas.
