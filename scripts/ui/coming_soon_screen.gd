extends ScreenBase
## Tela usada por botões que ainda não têm sistema completo implementado
## (Personagens, Loja, Conquistas, Configurações, etc.) — mantém a navegação
## sempre funcional enquanto esses sistemas são construídos nas próximas etapas.

func _ready() -> void:
	add_background_gradient()

func setup(params: Dictionary) -> void:
	var title: String = params.get("title", "Em breve")
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(root)
	root.add_child(make_label(title, 34, COLOR_ACCENT))
	root.add_child(spacer(12))
	root.add_child(make_label("Em construção — chega em uma próxima atualização!", 20, COLOR_TEXT_DIM))
	root.add_child(spacer(28))
	var back := make_button("Voltar ao menu", COLOR_PRIMARY)
	back.pressed.connect(func(): SceneRouter.go_to("main_menu"))
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(back)
