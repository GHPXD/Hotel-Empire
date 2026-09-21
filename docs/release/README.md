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
