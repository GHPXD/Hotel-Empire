# M8 — admissão e saídas (20/09/2026)

## Mudanças e contrato
GuestSystem filtra as recepções uma vez por step, em ordem de construção. Continua
tentando cada fila na mesma ordem. A lista vive somente nesse step; construção,
demolição e load não precisam invalidar um cache persistente. Ao liberar quarto,
um hóspede com bedroom=-1 retorna imediatamente, preservando o estado já liberado.
Nenhuma alteração de preço, capacidade, paciência, tick, RNG ou formato de save.

O teste admission_equivalence_test usa como referência a varredura anterior de todas
as salas por chegada e a liberação anterior sem atalho. Compara snapshots completos
em três seeds sob reposição de 250 hóspedes, incluindo reconstrução da primeira
recepção após outras categorias e continuidade de 100 ticks após save/load.

## Sobrecarga de chegadas
Mesmo hardware e método do README. Baseline anterior, admission.json com filtro
de recepções e admission-exit.json com os dois atalhos. Preparo da população e
validação não estão dentro da medição do tick. Não rodar testes em paralelo ao perfil.

| Alvo antes de cada tick | P95 original | Só recepções | Recepção + saída | Média final |
|---|---|---|---|---|
| 100 | 6,73 ms | 1,99 ms | 1,64 ms | 1,45 ms |
| 250 | 19,27 ms | 4,11 ms | 2,67 ms | 2,29 ms |
| 500 | 40,63 ms | 7,73 ms | 4,80 ms | 3,88 ms |
| 1000 | 83,35 ms | 16,85 ms | 9,28 ms | 7,42 ms |

P95 do maior caso caiu aproximadamente 89%. Máximo final: 10,13 ms. Mesmos totais
de saídas em cada caso, 53 hóspedes no fim e 41 pedidos de transporte; invariantes
passaram. O preparo do harness foi melhorado entre baseline e admission (contagem
uma vez por tick); esse preparo já era excluído da medição do tick no baseline.

## Cena integrada com HUD
integrated_profile.gd instancia main.tscn, aquece o render pausado por 30 frames,
injeta uma onda e executa 12 segundos de simulação a 1x. VSync desligado. Render,
HUD, IA e transporte operam pelos caminhos reais; resultado em integrated.json.
O contador de população é amostrado por tick; média de população ponderada por frames.

| Onda inicial | População média / final | P95 frame | Máximo frame | Frames >16,67 ms |
|---|---|---|---|---|
| 100 | 25,48 / 24 | 4,53 ms | 20,42 ms | 0,030% |
| 250 | 27,92 / 24 | 4,67 ms | 8,01 ms | 0% |
| 500 | 29,68 / 24 | 4,67 ms | 11,85 ms | 0% |
| 1000 | 31,58 / 24 | 4,56 ms | 20,43 ms | 0,062% |

Todos terminam com quatro reservas e estados checkin, caminhada, fila de elevador,
cabine, equipe ociosa/trabalhando. As recepções rejeitam a maior parte da onda.
Esses resultados NÃO comprovam 1000 hóspedes hospedados ou operação sustentada
nessa população. Tampouco garantem todos os frames a 60 FPS. O perfil integrado de
hotel preenchido, com serviços concorrentes e população efetiva, ainda falta antes
de fechar M8. Não alterar as regras para disfarçar a população efetivamente medida.

## Reproduzir
Dados de usuário isolados em .runtime; executáveis conforme ambiente local:

```powershell
godot --path . --script res://debug/performance_profile.gd -- --label=admission-exit --simulation-only
godot --path . --script res://debug/integrated_profile.gd
godot --headless --path . --script res://tests/admission_equivalence_test.gd
```

Flags render-only e simulation-only selecionam partes distintas do perfil; não usar
ambas juntas. Report de simulação retorna exit 1 se uma invariante falhar.
