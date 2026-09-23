# Interface e indicadores M6

## Fluxos entregues

- **Operação / F2**: resumo do hotel, lista com maior fila primeiro, filtros de tipo,
  andar e situação (com fila, precisa limpar, em uso). Enter ou botão inspeciona uma
  sala e centraliza a câmera. Esc fecha e retorna foco ao abridor. Seleção desaparecida
  por limpeza/demolição desabilita inspeção, sem apontar para outra sala.
- **Construção / Ctrl+F**: busca por nome, ignorando caixa e acentos portugueses,
  combinada com categoria. Nenhum resultado tem explicação textual; salas bloqueadas
  continuam identificadas como bloqueadas. Filtrar não altera instalações existentes.
- **Texto / F4**: alterna fonte padrão 16 para 20, aumenta largura da lateral e usa
  Theme compartilhada nos painéis. Preferência em `user://interface.cfg`; carregar
  hotel não altera preferência. Nova sessão/load reseta filtros, não a fonte.
- **Leitura e foco**: estados de hóspedes/equipe traduzidos, ausência de reserva/tarefa
  descrita, dados de utilidade somente no debug. Tab e foco dourado, Enter nos controles,
  Esc nos painéis; Equipe, Objetivos, Operação, Finanças e confirmação retornam foco
  ao abridor. Finanças usa extrato com rolagem. Operação mostra detalhes completos
  da seleção abaixo da lista, sem depender de tooltip para situação e andar.

## Significado dos indicadores

Todos os indicadores de Operação resumem o hotel inteiro, independentemente dos filtros.
Atualização visual a cada 0,2s; não há histórico de séries ou projeção de demanda.

| Indicador | Definição |
| --- | --- |
| Ocupação | Quartos reservados / quartos construídos, com zero seguro em hotel vazio |
| Limpeza pendente | Quartos com flag dirty, inclusive se a limpeza já começou |
| Filas nas salas | Soma das filas existentes das salas, incluindo reservas de lugar a caminho |
| Filas nos elevadores | Passageiros nas filas de transporte, sem os embarcados |
| Maior espera atual | Maior waiting de atores em check-in/fila de serviço/fila de elevador; check-in inclui o atendimento até obter quarto |
| Satisfação dos presentes | Média dos hóspedes ainda no hotel, excluindo equipe; traço quando não há hóspedes |
| Custo fixo | Manutenção atual mais salários por dia, mesma função usada na cobrança |
| Lucro acumulado | Receita menos despesas operacionais desde início; investimento é separado |

O resumo não confunde média dos presentes com reputação ou satisfação das visitas
concluídas. A lista usa filas de elevador reais, não a fila vazia de sua RoomState.
Poços aparecem em todos os filtros de andar, com o rótulo “todos os andares”.

## Verificação e limites

Testes determinísticos conferem métricas, filtros combinados, ordem, preferências
e snapshots inalterados. Teste gráfico usa eventos reais de viewport/PopupMenu para
busca, navegação, filtros, Enter, Esc e F4, além de comparar o snapshot pausado antes
e depois. Screenshots em `.runtime/m6-*.png` registram textos padrão/ampliados.

Dois problemas foram encontrados e corrigidos: busca vazia escondia o catálogo por
usar contains com string vazia; a condição agora trata explicitamente consulta vazia.
O teste de “nenhum resultado” alterava a propriedade text sem emitir o evento de
edição; agora digita pelo viewport, exercitando o fluxo usado pelo jogador.
Na inspeção visual, wrap_controls fazia Equipe crescer além da tela com texto
ampliado. O painel agora tem altura controlada e conteúdo rolável; o teste também
confere dimensões lógicas das janelas contra o viewport, sem misturar escala de textura.

Escopo: desktop, mouse e teclado nos fluxos cobertos. Posicionar construções no
terreno e selecionar hóspedes ainda requer mouse; não há suporte integral a controller,
touch, leitor de tela, RTL ou remapeamento de controles. Não se declara acessibilidade
completa. A fonte das legendas desenhadas no mundo segue o zoom da câmera; F4 amplia
os controles/painéis. Não há alteração de balanço, RNG, calendário ou schema de save.

## Diagnóstico de check-in — 22/09/2026

Selecionar uma recepção no inspetor ou em Operação (F2) mostra a causa atual da
espera do primeiro hóspede: deslocamento, ausência de recepcionista, atendimento,
limpeza, ocupação, orçamento ou falta de quarto acessível. O texto recomenda uma
ação e se atualiza sem exigir nova seleção. Detalhes têm rolagem e aceitam F4.
É uma leitura do próximo passo de admissão, não uma estatística histórica nem
uma previsão para todos os hóspedes. `CheckinDiagnostics` também alimenta o
observador dos benchmarks M9, sem alterar regras, estado persistido ou RNG.

Validação: a suíte de simulação observa bloqueio real por sujeira, contrata um
camareiro, confirma a reserva e depois distingue ocupação de disponibilidade.
A suíte visual verifica inspetor, painel, atualização e snapshot inalterado.
`tools/test.ps1 -Visual` passou nas 22 suítes; captura com texto ampliado
`.runtime/checkin-diagnosis.png` inspecionada sem corte da recomendação.

## Métricas por elevador — 23/09/2026

Ao selecionar um elevador em Operação, os detalhes mostram ocupação da cabine,
fila, maior espera atual, espera média/máxima até embarcar e totais de embarques
e viagens de passageiros concluídas. Incluem hóspedes e funcionários. Uma mesma
pessoa pode contar em várias viagens. O histórico pertence ao elevador e utiliza
os contadores já persistidos; a espera atual lê apenas os membros da fila.
Sem embarques, o painel informa ausência de histórico, em vez de sugerir que
ninguém esperou. Não há percentual de utilização: o tempo de existência de cada
elevador ainda não é registrado para calcular esse denominador corretamente.

`analytics_test` passou com embarque/desembarque reais e separação entre espera
pendente e concluída. `ui_operations` passou com teclado, texto ampliado e snapshot
inalterado. Captura `.runtime/m6-large-panel.png` inspecionada. Este incremento
ainda não foi incluído no ZIP da revisão `f8eb7b2`.
