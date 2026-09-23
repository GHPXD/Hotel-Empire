# M10 — preparação Windows

`tools/build_windows.ps1` exporta, verifica boot normal, executa o diagnóstico
`-- --release-smoke`, confere logs e cria ZIP com executável, instruções, licenças
e manifesto de hash/revisão. Requer Godot 4.7.2, templates Windows x86_64 e GPU
compatível com o renderer de compatibilidade. O pacote não requer o editor.
Não publica nem instala o jogo. Saída: `builds/HotelEmpire-windows-x86_64.zip`.

O script limita cada processo a 60 segundos e usa APPDATA isolado nos testes.
O diagnóstico é acionado somente por argumento explícito e escreve arquivos
`release-smoke-*`, sem ler ou substituir o save normal. Simula cinco dias mais
120 ticks de continuidade comparada após salvar/carregar; verifica conteúdo,
texturas, áudio e captura. Não mede FPS nem substitui playtest manual do pacote.
Também injeta cliques nos controles Godot Salvar/Carregar e verifica a restauração
completa da sessão após trocar por um hotel vazio. Não é automação do mouse do Windows.
O smoke abre Finanças, solicita saída, verifica a substituição do modal e cancela
com Escape, conferindo que a sessão permanece idêntica.
Também abre Ajuda pelo botão e a fecha com Escape, conferindo a pausa e a ausência
de alteração na sessão. O guia F1 reúne os primeiros passos, custos recorrentes,
gargalos, controles e save/load dentro do jogo; usa rolagem e o tema de texto ampliado.

O fechamento de uma partida agora oferece salvar, descartar ou continuar. A
simulação pausa sem alterar a velocidade selecionada. Erro de gravação mantém
o diálogo e o hotel abertos. Um hotel sem construção/atores/histórico fecha direto;
construção só de andares também é protegida. Não há detecção de alterações desde
o último save: uma partida construída sempre oferece a escolha ao sair.
`tests/ui_exit.gd` verifica esses caminhos com o diálogo real e intercepta apenas
o quit final, incluindo preservação dos bytes do save ao descartar. Em 21/09/2026,
as 18 suítes base/visuais passaram; o caso de outro modal foi acrescentado depois
e a suíte de saída repetida com sucesso.

Recuperação: se o save principal falhar, Carregar valida o `.bak` com as mesmas
regras de tamanho, formato e referências. Somente um backup válido é oferecido,
com dia/salas/caixa e confirmação para substituir a partida aberta. Cancelar mantém
o hotel; confirmar troca somente o estado em memória. Arquivos originais ficam
intactos até um salvamento posterior. A simulação pausa durante a escolha.
`ui_recovery` cobre corrupção/ausência do principal, backup inválido, precedência
do principal válido, cancelamento e preservação dos bytes. As 20 suítes base/visuais
passaram em 21/09/2026. O diagnóstico do pacote também cancela e confirma uma
recuperação em arquivos exclusivos de teste.

O primeiro preset por cena omitiu classes globais; foi corrigido para todos os
recursos com exclusão de testes, documentação e perfis. Boot normal e diagnóstico
do executável corrigido passaram. Evidência inicial: `windows-smoke.json/png`.

Os templates locais estavam incompletos (Android/Linux). Foram extraídos somente
os dois binários Windows do pacote oficial 4.7.2, após validar SHA256
`f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`.
Origem: https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable
Licenças copiadas de LICENSE.txt/COPYRIGHT.txt do mesmo tag em godotengine/godot.

Os templates oficiais não aceitam `--script` externo por padrão; argumentos
desconhecidos são ignorados. Por isso a verificação usa o diagnóstico interno,
conforme https://docs.godotengine.org/en/4.7/tutorials/editor/command_line_tutorial.html.

ZIP extraído em `builds/verification/Hotel Empire`: SHA256 do executável confere
com o manifesto; teste gráfico, operação e cliques de Salvar/Carregar passaram.
Relatório: 6120 ticks, 39 reservas, 42 refeições, 31 limpezas, caixa 8121, zero
falhas. Captura inspecionada em `windows-smoke.png`. Boot sem argumentos de teste
também passou. Esses resultados usam o executável oficial release, não o editor.

Matriz local: `tools/test_windows_package.ps1` valida o ZIP em seis combinações de
janela/texto; método, capturas e limites em `COMPATIBILITY.md`.
Pendências M10: validação externa de hardware e revisão final de distribuição.
Não há assinatura digital nem publicação nesta etapa. Os arquivos de licença do
Godot não atribuem uma licença nova ao código ou à arte do Hotel Empire.

## Atualização de 22/09/2026

Pacote da revisão `ce2ff2204ded1bb8c50087acec95f8eab9533c51`, árvore limpa no
build, inclui pinturas de upgrade de quarto/recepção e diagnóstico de check-in.
Boot normal e smoke passaram. O ZIP extraído passou nos seis casos de janela/texto;
evidência completa em `upgrade-diagnostics-matrix.json`. O smoke verifica também
carregamento das pinturas novas, texto do diagnóstico e snapshot inalterado.

ZIP SHA-256: `247d18e7067680b5490d0180bb02fccefd3f5059df634ce9f5d58f9e916d635f`.
Executável SHA-256: `db3357537c553e53359ab03b51aba7635691fa991c94bb1825fbf4342e7970db`.
As pendências de hardware externo e distribuição acima continuam abertas.

### Pacote atualizado — restaurante N2/N3

Revisão `80d51de9b6d79700bf63807709e32eddc06844f9`, árvore limpa no build.
Inclui as duas pinturas do restaurante e teste de compra/save/load dos upgrades
visuais. Boot e seis casos do ZIP extraído passaram; relatório em
`restaurant-upgrades-matrix.json`. A simulação continua com 6120 ticks, 39 reservas,
42 refeições e 31 limpezas. O caixa final é 5721 após 2400 gastos nas melhorias.
Captura de 1024×640 com texto ampliado inspecionada.

ZIP SHA-256: `eb6bfdf06328b5736925f54e3b6f47eab75931c6adc1ba7d81e00f1feea321e0`.
Executável SHA-256: `00124200363a6f565152fba683623e18cff62ac2aa9cceee14040a3880f075e9`.

### Pacote atualizado — quartos/recepção N3 e cabine N2

Revisão `c3f2b6a9853c7af9bd961180034734b43cca44ff`, árvore limpa no build.
Boot e seis casos do ZIP extraído passaram; `final-rooms-cabin-matrix.json`
registra os resultados. Compras reais de N3 para quarto, recepção e restaurante,
e N2 para elevador, preservadas após save/load. Caixa 3521 após os upgrades;
6120 ticks, 39 reservas, 42 refeições e 31 limpezas. Captura 1024×640 com texto
ampliado inspecionada. Cabine N3 distinta e compatibilidade externa seguem pendentes.

ZIP SHA-256: `a5db601a839a91af31deb8fc2be7d88b381e497cb6f82283957acd65493cbd6f`.
Executável SHA-256: `f7244f13107b475569604a74eb496fb7f11887b538bdf76f1ddc1ba0f8fca185`.

### Pacote atualizado — cabine N3 (23/09/2026)

Revisão `f8eb7b26cdb867e26bcbb9f0622b688316d5e6fd`, árvore limpa no build.
A cabine N3 agora tem pintura própria. Boot, compra dos upgrades N2/N3 e save/load
passaram nas seis combinações locais de janela/texto (`cabin3-matrix.json`).
6120 ticks, 39 reservas, 42 refeições, 31 limpezas e caixa 2021 após as compras.
Captura 1024×640 com texto ampliado inspecionada. A pendência de geração da cabine
foi resolvida; compatibilidade externa e revisão final de distribuição seguem abertas.

ZIP SHA-256: `31661155966d14f0f11e6693830207cbf82bde429e1f18ff56dd21854cbb0c2c`.
Executável SHA-256: `b7f7aba94dc47cb881697e4a1f8453e7530e59bf72a5f442840cecb34ef13283`.

### Pacote atualizado — métricas de elevador (23/09/2026)

Revisão `290bdcd270b4e7f6ee6286ae596724cfbad6474b`, árvore limpa no build.
Inclui métricas por elevador em Operação e no inspetor. O percentual incorreto
baseado na idade do hotel foi substituído por tempo ocupado acumulado.
Boot e seis combinações de janela/texto passaram (`elevator-metrics-matrix.json`).
O smoke verifica histórico real de transporte, concordância entre painel e
inspetor e snapshot inalterado; captura específica `release-elevator-metrics.png`
gerada em cada pasta de usuário isolada. Caso 1024×640 ampliado inspecionado.

ZIP SHA-256: `ac423e9899fafccaf222b8725a065192bd30b9a8bc485869e0966c495b61cfa6`.
Executável SHA-256: `5602c743a242991fe84400951e7b599016d0676774445ef2f9eec4337e452439`.
