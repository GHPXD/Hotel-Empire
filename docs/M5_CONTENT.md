# Conteúdo M5 e contrato de protótipo

O incremento acrescenta duas instalações, três perfis e dois eventos de calendário.
Fontes executáveis: `data/rooms/`, `data/guests/` e `data/events/`. Ainda usa arte
procedural e não inclui áudio, outros tipos de funcionários ou melhorias nas novas salas.

## Serviços e escolhas

| Instalação | Construção / manutenção diária | Capacidade / duração | Tarifa / alívio | Liberação |
| --- | --- | --- | --- | --- |
| Café Brisa | $700 / $12 | 2 / 4s | $16 / 40 de fome | Primeiras estadias |
| Sala Horizonte | $1200 / $18 | 3 / 12s | $24 / 70 de entretenimento | Operação completa |
| Bistrô, referência N1 | $1000 / $16 | 3 / 8s | $28 / 85 de fome | Inicial |

Meta: opções situacionais. Na mesma posição com fome 44 e entretenimento 40,
o perfil equilibrado escolhe bistrô, negócios escolhe café, lazer escolhe sala de lazer.
Com fome 90, negócios deve preferir refeição completa. Nenhum hóspede escolhe um
serviço pago sem saldo. Esses limites são testes determinísticos, não taxas de escolha
esperadas para toda partida.

A utilidade parte de `min(necessidade ponderada, alívio)` e desconta distância ×0,6,
fila ×4 e, para serviços, tarifa ×peso de preço e duração ×peso de rapidez. Adiciona
o bônus de satisfação do upgrade. Sala sem acesso ou fila cheia é excluída. Definições
de serviço determinam necessidade e alívio; o código não contém roteiro específico
para café ou lazer. Hospedagem continua pré-paga no check-in.

| Perfil | Orçamento | Peso preço / rapidez | Entretenimento: crescimento/s / peso | Estadia / paciência |
| --- | --- | --- | --- | --- |
| Equilibrado | $320 | 0,15 / 0 | 0,1 / 1 | 1× / 1× |
| Negócios | $420 | 0,1 / 0,8 | 0,1 / 1 | 0,85× / 0,9× |
| Lazer | $360 | 0,15 / 0 | 0,85 / 1,7 | 1,15× / 1,15× |

O RNG da sessão sorteia os perfis com a mesma probabilidade. Multiplicadores de
estadia/paciência usam os valores base de SimulationRules; paciência vale nas filas
de atendimento. A penalidade de espera no elevador permanece comum. Atores existentes
de saves antigos recebem perfil equilibrado sem recalcular o dinheiro que possuíam.

## Eventos

Feira da cidade acelera o temporizador de chegadas por 1,5; Dias tranquilos por 0,65.
Começam alternadamente a cada três dias de 120s e duram um dia. A primeira feira
começa após 360s (HUD já mostra dia 4), seguida de dois dias sem modificador. O jogo
não injeta caixa nem altera tarifas durante eventos. Fechar chegadas evita novos
hóspedes, mas não interrompe calendário, manutenção ou salários; pausa interrompe ticks.

Meta determinística: início exato, duração exata, sem sobreposição, mesma fase após
save/load e nenhuma chegada quando fechado. Em um cenário isolado de 30s, seed 42,
ocorreram 5 chegadas normais, 7 na feira e 4 nos dias tranquilos. Esses inteiros não
medem uma proporção estatística; verificam o sentido do efeito.

## Operação e diagnóstico

Três seeds (1, 17, 123) constroem o template padrão com $250.000 e operam normalmente
por dois dias até liberar conteúdo. Depois adicionam café no primeiro andar, junto
ao elevador, e sala de lazer em novo terceiro andar. Por mais seis dias, inserem um
hóspede a cada 20s com chegadas automáticas fechadas. Ambos os serviços devem ser
usados, sem violar conservação de agentes, caixa, capacidade ou referências.

| Seed | Receita do café | Receita da sala de lazer | Serviços / refeições acumulados |
| --- | --- | --- | --- |
| 1 | $80 | $480 | 107 / 87 |
| 17 | $96 | $504 | 102 / 81 |
| 123 | $16 | $360 | 91 / 76 |

Isso comprova uso e integração, não retorno do investimento. Antes de controlar a
demanda, o café recebeu zero ou uma visita por seed com chegadas contínuas. Movê-lo
para perto dos quartos não resolveu consistentemente. Aumentar temporariamente o
peso de rapidez de negócios de 0,8 para 4 também não alterou o resultado; foi revertido.
As diferenças entre cenários mostram dependência da operação. Ainda não isolamos
quanto do baixo uso vem de fila, fome acumulada, localização ou término da estadia.
Não declarar as duas opções economicamente equilibradas ou igualmente úteis.

Próximo experimento: manter seed/topologia e variar uma condição por vez — chegadas,
localização do café, duração de check-in — registrando oportunidades com saldo e
acesso, escolhas por perfil, fome no momento da escolha, filas e lucro incremental.
Se café continuar sem uso em cenários que deveriam favorecê-lo, rever alívio/custo
com um ajuste de cada vez e reexecutar o conjunto. Parâmetros e reversões ficam em Git.
Sem telemetria remota ou conclusão sobre preferência de jogadores humanos.

## Persistência e QA

Schema v4 adiciona `archetype_id` e `service_uses`. Refere-se a serviços pagos,
sem contar hospedagem; somente serviços de fome incrementam refeições. V1–v3 migram,
preservando acesso legado a N3, mas sem liberar novas salas sem objetivos. Eventos
derivam do tick salvo, sem estado paralelo. As regras atuais governam a partida
migrada; não se promete reproduzir simulações executadas por versões antigas.

Dados de regressão em `benchmarks/m5-content.json`. Testes incluem migração de save
real v3, 1.500 ticks de continuidade de serviços, 5.000 ticks atravessando eventos,
UI com entrada de viewport, pausa, retomada e janela menor. As suítes anteriores
continuam cobrindo stress e 20 checkpoints de save em cinco seeds.
