extends ScreenBase
class_name MainMenuScreen

func _ready() -> void:
	add_background_gradient()

	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.add_theme_constant_override("margin_left", 24)
	top_margin.add_theme_constant_override("margin_right", 24)
	top_margin.add_theme_constant_override("margin_top", 24)
	top_margin.add_child(build_top_bar())
	add_child(top_margin)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	root.add_child(make_label("ROLL ADVENTURE", 44, COLOR_ACCENT))
	root.add_child(make_label("Pequenas ações, grandes aventuras", 18, COLOR_TEXT_DIM))
	root.add_child(spacer(16))
	root.add_child(make_label("🔵", 90))
	root.add_child(spacer(16))

	var play_button := make_button("▶  JOGAR", COLOR_SUCCESS, Vector2(320, 84))
	play_button.pressed.connect(func(): SceneRouter.go_to("world_select"))
	play_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(play_button)
	root.add_child(spacer(6))

	var characters_btn := _menu_button("PERSONAGENS")
	var worlds_btn := _menu_button("MUNDOS", func(): SceneRouter.go_to("world_select"))
	var achievements_btn := _menu_button("CONQUISTAS")
	var settings_btn := _menu_button("CONFIGURAÇÕES")
	for b in [characters_btn, worlds_btn, achievements_btn, settings_btn]:
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		root.add_child(b)

func _menu_button(text: String, on_press: Callable = Callable()) -> Button:
	var button := make_button(text, Color(1, 1, 1, 0.08), Vector2(280, 58))
	if on_press.is_valid():
		button.pressed.connect(on_press)
	else:
		button.pressed.connect(func(): SceneRouter.go_to("coming_soon", {"title": text}))
	return button
