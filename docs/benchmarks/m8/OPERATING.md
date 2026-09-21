# M8 — operação contínua (20/09/2026)

## Escopo e conclusão
O limite atual de SimulationRules.max_guests é 120, não 1000. M8 conclui o perfil
e a otimização desta versão: render/transportes/sobrecarga até 1000 e operação
integrada até a capacidade atual. Operação hospedada com 500–1000 permanece meta
futura, dependente de conteúdo/capacidade, regras e nova medição; não é certificada.

## Método
operating_profile.gd instancia main.tscn com HUD, câmera padrão e arte M7. Prepara
300 segundos por ticks reais de IA/economia/transporte; não atribui quartos nem
estados artificialmente. Aquece 30 frames pausados e mede 30 segundos simulados
em 1x, seguidos de 30 em 3x. VSync desativado. Mesmo Ryzen 7 5700U/Radeon integrada,
Windows, Godot 4.7.2 Compatibility. Resultados brutos: operating.json.

- Normal: template padrão, 12 quartos e procura normal via HotelSession.opened.
- Demanda controlada: 20 andares, quatro recepções, quatro restaurantes, quatro
  elevadores, 108 quartos, quatro recepcionistas e 12 funcionários de limpeza.
  O harness oferece uma chegada por segundo e respeita o limite de 120 hóspedes.
  Desativa somente as chegadas automáticas para não duplicar a fonte; não modifica
  orçamento, paciência, estadia, preços, velocidades, necessidades ou prioridades.
- O caixa inicial de teste é 1.000.000 para financiar a estrutura. Isto é perfil de
  desempenho, não prova de viabilidade financeira desse hotel em uma partida nova.
- Métricas são amostradas por tick; validação de referências/conservação após cada
  fase, fora dos tempos. Cronômetro de frames exclui o trabalho do próprio coletor.

| Cenário | Velocidade | Hóspedes min–max | Reservados (pico) | Novas reservas/refeições/limpezas | P95 frame | Máximo |
|---|---|---|---|---|---|---|
| Normal | 1x | 15–18 | 8 | 2 / 3 / 2 | 4,34 ms | 16,73 ms |
| Normal | 3x | 15–18 | 6 | 3 / 3 / 4 | 4,41 ms | 5,95 ms |
| Controlado | 1x | 118–120 | 35 | 2 / 2 / 2 | 5,70 ms | 7,02 ms |
| Controlado | 3x | 118–120 | 35 | 3 / 0 / 3 | 5,96 ms | 7,56 ms |

Estados observados incluem serviço, check-in, caminhada, cabine,
fila de elevador, limpeza, decisão e trabalho. 'using' foi observado; a coluna
de quartos reservados não equivale a pessoas fisicamente dentro do quarto.
No cenário controlado, o frame não excedeu 16,67 ms nas amostras. No normal a 1x,
um frame excedeu esse orçamento (0,011%). Não garante ausência de stutter universal.

A população alta persiste por 60 segundos simulados depois de 300 de preparação;
não é a onda anterior que caía a 24. O baixo giro de reservas e refeições no hotel
alto revela gargalo de operação/transporte, a ser analisado no QA/balanceamento M9.
Não remover filas ou reduzir hóspedes para melhorar artificialmente o perfil.

## Reproduzir
Usar APPDATA isolado em .runtime e executar sem outros benchmarks:

```powershell
godot --path . --script res://debug/operating_profile.gd
```

O relatório salva em .runtime/m8-operating.json. Exit 1 se invariante falhar.
Não é soak de longa duração nem teste de export, driver diferente ou hardware mínimo.
