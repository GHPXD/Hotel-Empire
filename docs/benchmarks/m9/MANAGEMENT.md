# Comparação de decisões de gestão

Contrato definido antes da execução: hotel inicial de oito quartos, orçamento
normal de $12000, chegadas naturais, seeds 1/17/123, 30 dias. Comparar reputação,
reservas, refeições, caixa e espera. Investimentos devem preservar solvência e
invariantes; não se exige antecipadamente que toda expansão melhore reputação.
Uma queda consistente nas três seeds pede investigação do mecanismo antes de
alterar números. Nenhum parâmetro de produção é alterado neste experimento.

Quatro políticas: estática; serviços (café e lounge); capacidade (segundo camareiro,
elevador N2 e quatro quartos); combinada (serviços, depois capacidade). Uma compra
por dia a partir do quinto dia, na ordem descrita, mantendo $1000 após a compra.
Compras sem fundos ou ainda bloqueadas aguardam o próximo dia. Custos recorrentes
continuam normais. Não há injeção de dinheiro nem hóspedes artificiais.

`debug/management_profile.gd` grava `.runtime/m9-management.json`. Métricas de fila
incluem episódios concluídos por atendimento ou abandono e reportam pendências
separadas. Estados são amostrados a cada dez segundos; não equivalem a contagens
de hóspedes únicos. O perfil é uma comparação controlada de políticas fixas, não
uma prova de estratégia ótima nem um substituto de playtest humano.

## Resultado — 21/09/2026

Doze cenários completos, 36000 ticks cada, sem falhas. Todas as compras planejadas
foram concluídas; caixa mínimo $2370 em todos. Dados brutos: `management.json`.

| Política | Reservas | Caixa final | Reputação final | Espera média check-in (s) |
|---|---|---|---|---|
| Estática | 226–228 | 34832–35112 | 48,42–53,22 | 65,28–66,27 |
| Serviços | 228–232 | 33942–34726 | 48,73–49,97 | 65,37–66,40 |
| Capacidade | 363–372 | 51892–53684 | 58,33–62,11 | 60,81–61,45 |
| Combinada | 368–370 | 53014–53790 | 64,81–69,54 | 60,48–61,26 |

Capacidade alcançou trusted_hotel nas três seeds entre dias 6,37 e 7,21;
combinada entre dias 7,60 e 8,16. O objetivo é permanente após obtido: não implica
reputação final acima de 65. Estática e serviços não o obtiveram.

Interpretação: a combinação tem reputação final maior que capacidade nas três
seeds, mas também compra capacidade dois dias depois. Portanto não isola o efeito
de cada serviço. Serviços sozinhos não resolvem o gargalo inicial; capacidade
aumenta reservas em todas as seeds. A espera em serviços permanece abaixo de
0,1 segundo em média, enquanto check-in passa de um minuto. A fila de recepção
inclui espera por quarto limpo disponível; não atribuir toda a demora ao tempo
de atendimento. Próximo experimento deve distinguir falta de quartos, limpeza e
capacidade da recepção, mantendo constantes as demais decisões.

Execução: Godot headless com `--path C:/Projects/HotelEmpire --script
res://debug/management_profile.gd`, APPDATA isolado em `.runtime`. Catálogo validado
via gda. A primeira execução do diagnóstico usou um nome incorreto de campo de
custo; foi interrompida, corrigida para `build_cost` e repetida integralmente.
Somente os dados da execução corrigida estão versionados. Sem ajuste nas regras.
