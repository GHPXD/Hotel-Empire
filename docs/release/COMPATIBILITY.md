# Compatibilidade do pacote Windows

Em 21/09/2026, `tools/test_windows_package.ps1` verificou o inventário do ZIP antes
da extração, comparou o SHA256 do executável com o manifesto e executou seis
casos em uma pasta separada com espaços. Cada caso usa APPDATA exclusivo e limite
de 60 segundos. Dados e capturas inspecionadas: `compatibility/matrix.json`.

Ambiente observado: Windows 10.0.26200, AMD Radeon(TM) Graphics, renderer
gl_compatibility, template oficial Godot 4.7.2 Windows x86_64. O número de versão
do kernel não é usado para inferir compatibilidade com outras edições do Windows.

| Janela solicitada e observada | Texto normal | Texto ampliado | Captura do viewport |
|---|---|---|---|
| 1024 × 640 | Passou | Passou | 1024 × 640 |
| 1280 × 800 | Passou | Passou | 1280 × 800 |
| 1600 × 900 | Passou | Passou | 1440 × 900 |

O viewport lógico permanece em 1440 × 900. A captura vem da textura do viewport,
não da área de trabalho: em 1600 × 900 ela exclui as margens externas de ajuste
de aspecto. Não interpretar esse PNG como uma captura integral da janela nativa.

Nos seis casos: zero falhas, 6120 ticks, 39 reservas, 42 refeições, 31 limpezas,
caixa 8121, roundtrip/continuidade do save e restauração pela barra de ferramentas.
O diagnóstico confirma que os retângulos dos controles essenciais cabem no
viewport; a inspeção visual confere catálogo, alertas, texto, arte e rodapé.
A opção ampliada é aplicada antes do clique de Carregar e sobrevive à troca da
partida. Os cliques são eventos Godot; não certificam drivers físicos de mouse.

Inventário permitido: executável, LEIA-ME, licença Godot, avisos de terceiros e
manifesto. Testes/documentação do repositório não entram nos recursos do jogo.
O manifesto identifica a revisão e indica quando havia alterações locais no build.

## Ainda não verificado

- Outras GPUs, drivers, computadores e versões de Windows; não há requisito
  mínimo de hardware certificado com apenas esta máquina.
- DPI/escalas de desktop diferentes, múltiplos monitores, fullscreen e suspensão.
- Linux, macOS, Web e dispositivos móveis: não são distribuições suportadas por
  este ZIP. A arquitetura mantém essas possibilidades futuras.
- Assinatura digital, instalador, atualização automática e publicação em loja.

A matriz local não encerra a validação externa. A próxima revisão de distribuição
deve manter estes limites explícitos e acrescentar resultados reais de outras
máquinas quando disponíveis.

## Kit independente para coleta externa — 23/09/2026

`tools/build_compatibility_kit.ps1` empacota o ZIP atual, o validador PowerShell,
um iniciador e o roteiro `EXTERNAL-TEST.txt` em
`builds/HotelEmpire-compatibility-kit.zip`. Extraia o kit e execute
`powershell -NoProfile -File .\Start-Validation.ps1` na pasta extraída.
O kit dispensa Godot/repositório e grava dados isolados em `results`.
O ZIP de resultados contém logs, capturas, matriz e versão do PowerShell,
incluindo diagnóstico de falha; não inclui executável, caches ou saves.
Não transmite dados. Caminhos locais e informações de GPU/OS constam dos relatórios.

Validação local do kit: Windows PowerShell, extração em caminho com espaços,
seis casos aprovados e relatório compactado produzido. Pacote ausente retorna
falha e produz relatório. Um problema com caminhos longos no cache de shaders
foi corrigido coletando apenas arquivos conhecidos, sem percorrer caches.
Evidência: `external-kit-local-matrix.json`. Isso comprova a operação do kit nesta
máquina, não compatibilidade externa. O roteiro inclui as verificações manuais
de entrada, leitura, áudio, saves e suspensão que o smoke não certifica.
