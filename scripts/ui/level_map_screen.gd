extends ScreenBase
class_name LevelMapScreen

var _content: VBoxContainer

func _ready() -> void:
	add_background_gradient()

	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.add_theme_constant_override("margin_left", 24)
	top_margin.add_theme_constant_override("margin_right", 24)
	top_margin.add_theme_constant_override("margin_top", 24)
	top_margin.add_child(build_top_bar(func(): SceneRouter.go_to("world_select")))
	add_child(top_margin)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 110)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 16)
	margin.add_child(_content)

func setup(params: Dictionary) -> void:
	var world_id: String = params.get("world_id", "floresta")
	var world := GameManager.get_world(world_id)
	_content.add_child(make_label(String(world.get("name", "")).to_upper(), 30, COLOR_ACCENT))

	var levels: Array = GameManager.get_levels(world_id)
	if levels.is_empty():
		_content.add_child(spacer(20))
		_content.add_child(make_label("Novas fases chegam em breve!", 20, COLOR_TEXT_DIM))
		return

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(grid)

	for level in levels:
		grid.add_child(_build_level_node(world_id, level))

func _build_level_node(world_id: String, level: Dictionary) -> PanelContainer:
	var unlocked: bool = level["unlocked"]
	var panel := make_panel(Color(1, 1, 1, 0.1) if unlocked else Color(1, 1, 1, 0.04))
	panel.custom_minimum_size = Vector2(160, 160)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	box.add_child(make_label(String(level["name"]), 18, COLOR_TEXT if unlocked else COLOR_TEXT_DIM))
	if unlocked:
		var stars: int = level["stars"]
		box.add_child(make_label("⭐".repeat(stars) + "☆".repeat(3 - stars), 16, COLOR_ACCENT))
		var button := make_button("Jogar", COLOR_PRIMARY, Vector2(110, 48))
		var level_id: String = level["id"]
		button.pressed.connect(func(): SceneRouter.go_to("game", {"world_id": world_id, "level_id": level_id}))
		box.add_child(button)
	else:
		box.add_child(make_label("🔒", 24))

	return panel
