# Diagnóstico do check-in

Contrato: repetir hotel de oito quartos, 30 dias, seeds 1/17/123, caixa normal e
chegadas naturais. Isolar uma decisão por política: nenhuma; segundo camareiro;
recepção N2; quatro quartos adicionais; elevador N2. Primeira compra no dia 5,
uma compra por dia, reserva de $1000. Não ajustar regras neste diagnóstico.
Solvência, compras concluídas e invariantes continuam obrigatórias.

Observador `debug/checkin_metrics.gd`: antes de cada tick, identifica o bloqueio
da cabeça da fila e atribui a ele o tempo de todos os hóspedes já em check-in
naquela fila. Unidade: hóspede-segundo, uma medida de exposição acumulada. Não é
contagem de pessoas, espera média individual nem prova isolada de causalidade.
A comparação das intervenções complementa a observação.

Prioridade das categorias: cabeça ainda em deslocamento; falta de recepcionista
trabalhando; processamento ainda não concluído; pronto para admitir; quarto livre
sujo; todos os quartos elegíveis ocupados; preço inacessível; ausência de quarto
acessível. Elegível significa acessível e dentro do dinheiro do hóspede da frente.
Mede o estado antes de funcionários/transporte avançarem: uma liberação durante
o tick pode antecipar em 0,1 s o atendimento em relação à categoria observada.
O observador não consome RNG nem modifica a sessão.

Execução: mesmo comando de `MANAGEMENT.md`, acrescentando `-- --checkin`.
Saída `.runtime/m9-checkin.json`. Dados das políticas anteriores permanecem
separados em `management.json`.

## Resultado — 21/09/2026

Quinze cenários de 36000 ticks passaram, com compras concluídas, solvência e
invariantes preservadas. Dados brutos em `checkin.json`. Todas as métricas das três
partidas estáticas são exatamente iguais à referência anterior, inclusive filas,
caixa, reputação e estados amostrados. Nenhuma regra de produção foi alterada.

| Intervenção | Reservas | Reputação final | Espera média check-in (s) |
|---|---|---|---|
| Nenhuma | 226–228 | 48,42–53,22 | 65,28–66,27 |
| Segundo camareiro | 327–335 | 56,94–65,07 | 61,83–62,52 |
| Recepção N2 | 226–229 | 49,25–54,08 | 65,16–65,94 |
| Quatro quartos | 226–231 | 52,40–54,04 | 65,20–66,06 |
| Elevador N2 | 229–232 | 51,02–57,09 | 65,40–65,82 |

Agregando hóspede-segundos das três seeds estáticas: limpeza 60,91%, processamento
38,27%, ocupação 0,69%, pronto 0,13%; deslocamento da cabeça abaixo de 0,01%.
Com segundo camareiro: limpeza 52,88%, processamento 44,92%, ocupação 1,87% e
pronto 0,33%. A categoria processamento aumenta proporcionalmente porque outras
esperas diminuem; não interpretar percentuais como durações absolutas.

Conclusão restrita a esse layout: limpeza é o primeiro gargalo acionável. O segundo
camareiro aumenta reservas nas três seeds; só acrescentar quartos não resolve o
retorno dos quartos ao estoque limpo. Atribuir o ganho da política `capacity` do
experimento anterior apenas aos quartos seria incorreto. A fila segue longa porque
a procura também responde à reputação e porque a limpeza ainda é restritiva.
Não se demonstra aqui que mais funcionários sejam sempre rentáveis ou que todos
os mapas devam usar duas pessoas; hotéis altos envolvem outra carga de transporte.

Decisão: preservar os parâmetros atuais; o jogo já oferece uma intervenção eficaz
e o alerta existente identifica quartos aguardando limpeza. A próxima etapa é a
revisão final da QA e validação conjunta antes da preparação de export.
