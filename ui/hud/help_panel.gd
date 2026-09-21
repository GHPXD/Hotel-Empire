class_name HotelHelpPanel
extends Window

var details: RichTextLabel

const GUIDE: String = """[b]SEU PRIMEIRO HOTEL[/b]
1. No catálogo, escolha uma Recepção e clique no térreo para construir.
2. Acrescente quartos e um Bistrô. Comece compacto e mantenha dinheiro para salários e manutenção.
3. Para construir acima do térreo, compre um andar e um Elevador. O poço precisa de espaço livre e atende os andares existentes automaticamente.
4. Abra Equipe e contrate recepcionista e camareiro. Eles procuram trabalho automaticamente; você também pode definir suas atribuições.
5. Clique em Abrir hotel. Observe as chegadas, as filas e o caixa antes de expandir.

[b]ENTENDA OS GARGALOS[/b]
Fila na recepção não significa apenas atendimento lento: o primeiro hóspede também pode estar esperando um quarto livre e limpo.
Quartos marcados LIMPAR precisam de camareiro. Acrescentar quartos sem capacidade de limpeza pode não resolver a fila.
Muita espera no elevador pede revisão do transporte. Selecione uma instalação para ver seus dados e melhorias; elas custam dinheiro.
Use Operação (F2), Equipe e Finanças para investigar. Objetivos mostra o que libera novos serviços. Salários e manutenção continuam mesmo com as chegadas fechadas.

[b]CÂMERA E CONSTRUÇÃO[/b]
Roda do mouse: zoom. Botão do meio: arrastar câmera.
Clique esquerdo: construir ou selecionar. Botão direito/Esc: cancelar a construção.
+ Andar: expandir para cima. Demolição não devolve dinheiro e pode ser bloqueada enquanto uma sala estiver em uso.

[b]CONTROLES[/b]
Espaço: pausar/retomar. Botões 1x, 2x e 3x: velocidade.
Ctrl+F: buscar uma construção. F2: Operação. F3: informações de debug.
F4: ampliar texto. F1: abrir esta ajuda. Esc: fechar um painel.
Som: ligar/desligar efeitos. Esta ajuda pausa o hotel; ao fechar, a velocidade anterior é mantida.

[b]SALVAR E CONTINUAR[/b]
Clique em Salvar ou use Ctrl+S. Não há autosave.
Carregar retoma o arquivo salvo. Novo hotel pede confirmação e preserva esse arquivo.
Ao fechar a janela, escolha salvar, sair sem salvar ou continuar jogando. Se a gravação falhar, o jogo permanece aberto.
"""

func _ready() -> void:
	title = "Como jogar Hotel Empire"
	size = Vector2i(680, 520)
	min_size = Vector2i(450, 300)
	wrap_controls = true
	hide()
	close_requested.connect(hide)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	add_child(margin)
	var column := VBoxContainer.new()
	margin.add_child(column)
	details = RichTextLabel.new()
	details.bbcode_enabled = true
	details.text = GUIDE
	details.focus_mode = Control.FOCUS_ALL
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.custom_minimum_size = Vector2(400, 220)
	column.add_child(details)
	var close := Button.new()
	close.text = "Voltar ao hotel"
	close.custom_minimum_size.y = 42
	close.pressed.connect(hide)
	column.add_child(close)

func open_guide() -> void:
	popup_centered()
	details.scroll_to_line(0)
	details.grab_focus()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
		set_input_as_handled()
