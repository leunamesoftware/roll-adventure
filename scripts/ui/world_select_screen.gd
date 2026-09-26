extends ScreenBase
class_name WorldSelectScreen

func _ready() -> void:
	add_background_gradient()

	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.add_theme_constant_override("margin_left", 24)
	top_margin.add_theme_constant_override("margin_right", 24)
	top_margin.add_theme_constant_override("margin_top", 24)
	top_margin.add_child(build_top_bar(func(): SceneRouter.go_to("main_menu")))
	add_child(top_margin)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 110)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	root.add_child(make_label("SELEÇÃO DE MUNDOS", 30, COLOR_ACCENT))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	scroll.add_child(row)

	for world in GameManager.get_worlds():
		row.add_child(_build_world_card(world))

func _build_world_card(world: Dictionary) -> PanelContainer:
	var unlocked: bool = world["unlocked"]
	var panel := make_panel(Color(1, 1, 1, 0.1) if unlocked else Color(1, 1, 1, 0.04))
	panel.custom_minimum_size = Vector2(240, 320)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	box.add_child(make_label(String(world["name"]), 20, COLOR_TEXT if unlocked else COLOR_TEXT_DIM))
	box.add_child(spacer(4))
	box.add_child(make_label("🌎" if unlocked else "🔒", 56))
	box.add_child(spacer(4))
	box.add_child(make_label("⭐ %d/%d" % [world["stars_earned"], world["stars_total"]], 16, COLOR_TEXT_DIM))
	box.add_child(spacer(8))

	var world_id: String = world["id"]
	if unlocked:
		var play_btn := make_button("JOGAR", COLOR_SUCCESS, Vector2(180, 56))
		play_btn.pressed.connect(func(): SceneRouter.go_to("level_map", {"world_id": world_id}))
		box.add_child(play_btn)
	else:
		var locked_btn := make_button("BLOQUEADO", Color(1, 1, 1, 0.08), Vector2(180, 56))
		locked_btn.disabled = true
		box.add_child(locked_btn)

	return panel
