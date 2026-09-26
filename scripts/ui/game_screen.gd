extends ScreenBase
class_name GameScreen
## Tela de gameplay: monta a fase via LevelBuilder, câmera, HUD (vidas, moedas, gemas,
## tempo, objetivos), controles (joystick + pular + poder) e as telas de pausa,
## vitória e derrota como overlays.

var _world_id: String = ""
var _level_id: String = ""
var _level_builder: LevelBuilder
var _camera: Camera2D
var _hud: Control

var _hearts_label: Label
var _coins_label: Label
var _gems_label: Label
var _timer_label: Label
var _objectives_label: Label

var _elapsed: float = 0.0
var _paused_or_ended: bool = false
var _overlay_nodes: Array = []

## Margem generosa acima/abaixo da fase: em telas com proporção bem diferente de
## 16:9, a câmera pode precisar mostrar mais altura do que a fase "oficial" tem.
## Sem essa folga, o Camera2D não consegue respeitar o limite e a área extra
## aparece vazia (sem fundo desenhado). Os limites laterais ficam justos mesmo,
## porque a fase é bem mais larga que qualquer celular.
const VERTICAL_CAMERA_MARGIN := 500

func _ready() -> void:
	set_process(true)

func setup(params: Dictionary) -> void:
	_world_id = params.get("world_id", "floresta")
	_level_id = params.get("level_id", "fase_1")
	GameManager.start_level(_world_id, _level_id)

	var world_layer := Node2D.new()
	add_child(world_layer)

	_level_builder = LevelBuilder.new()
	world_layer.add_child(_level_builder)
	_level_builder.build_from_file(GameManager.get_level_data_path(_world_id, _level_id))
	_level_builder.goal_reached.connect(_on_goal_reached)
	_level_builder.player_died.connect(_on_player_died)

	_camera = Camera2D.new()
	_camera.enabled = true
	_camera.limit_left = 0
	_camera.limit_top = -VERTICAL_CAMERA_MARGIN
	_camera.limit_right = int(_level_builder.level_size.x)
	_camera.limit_bottom = int(_level_builder.level_size.y) + VERTICAL_CAMERA_MARGIN
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 6.0
	_level_builder.player.add_child(_camera)

	_build_hud()
	_build_controls()

	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.gems_changed.connect(_on_gems_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.objective_progress_changed.connect(_on_objectives_changed)

## --- HUD ---

func _build_hud() -> void:
	_hud = Control.new()
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hud)

	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_margin.add_theme_constant_override("margin_left", 16)
	top_margin.add_theme_constant_override("margin_right", 16)
	top_margin.add_theme_constant_override("margin_top", 16)
	_hud.add_child(top_margin)

	var top_column := VBoxContainer.new()
	top_column.add_theme_constant_override("separation", 6)
	top_margin.add_child(top_column)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 14)
	top_column.add_child(top_row)

	var pause_btn := make_button("⏸", Color(1, 1, 1, 0.14), Vector2(52, 52))
	pause_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_btn.pressed.connect(_show_pause)
	top_row.add_child(pause_btn)

	var world_name: String = String(GameManager.get_world(_world_id).get("name", ""))
	var level_name: String = String(GameManager.get_level_entry(_world_id, _level_id).get("name", ""))
	var title_box := VBoxContainer.new()
	title_box.add_child(make_label(world_name.to_upper(), 13, COLOR_TEXT_DIM))
	title_box.add_child(make_label(level_name, 18, COLOR_ACCENT))
	top_row.add_child(title_box)

	_hearts_label = make_label("", 22, COLOR_DANGER)
	top_row.add_child(_hearts_label)

	_coins_label = make_label("", 18, COLOR_ACCENT)
	top_row.add_child(_coins_label)

	_gems_label = make_label("", 18, Color(0.4, 0.85, 0.95))
	top_row.add_child(_gems_label)

	_timer_label = make_label("⏱ 00:00", 18, COLOR_TEXT_DIM)
	top_row.add_child(_timer_label)

	_objectives_label = make_label("", 15, COLOR_TEXT)
	_objectives_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_column.add_child(_objectives_label)

	_on_coins_changed(0)
	_on_gems_changed(int(SaveManager.data.get("gems_total", 0)))
	_on_lives_changed(GameManager.lives)
	_on_objectives_changed(0, GameManager.current_coin_target, false)

func _build_controls() -> void:
	var bottom_margin := MarginContainer.new()
	bottom_margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_margin.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_margin.add_theme_constant_override("margin_left", 28)
	bottom_margin.add_theme_constant_override("margin_right", 28)
	bottom_margin.add_theme_constant_override("margin_bottom", 28)
	_hud.add_child(bottom_margin)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_margin.add_child(row)

	var joystick := VirtualJoystick.new()
	joystick.mouse_filter = Control.MOUSE_FILTER_STOP
	joystick.direction_changed.connect(func(v: float): _level_builder.player.set_direction(v))
	row.add_child(joystick)

	var middle_spacer := Control.new()
	middle_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(middle_spacer)

	var action_box := HBoxContainer.new()
	action_box.add_theme_constant_override("separation", 18)
	row.add_child(action_box)

	var power_btn := make_button("⚡", Color(0.9, 0.7, 0.1, 0.4), Vector2(72, 72))
	power_btn.disabled = true
	action_box.add_child(power_btn)

	var jump_btn := make_button("⬆", COLOR_PRIMARY, Vector2(84, 84))
	jump_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	jump_btn.button_down.connect(func(): _level_builder.player.request_jump())
	action_box.add_child(jump_btn)

## --- Loop ---

func _process(delta: float) -> void:
	if _paused_or_ended or _level_builder == null or _level_builder.player == null:
		return
	_elapsed += delta
	_timer_label.text = "⏱ %s" % _format_time(_elapsed)

	var kb_dir := 0.0
	if Input.is_action_pressed("move_left"):
		kb_dir -= 1.0
	if Input.is_action_pressed("move_right"):
		kb_dir += 1.0
	if kb_dir != 0.0:
		_level_builder.player.set_direction(kb_dir)
	if Input.is_action_just_pressed("jump"):
		_level_builder.player.request_jump()
	if Input.is_action_just_pressed("pause_game"):
		_show_pause()

## --- Sinais do GameManager ---

func _on_coins_changed(total: int) -> void:
	_coins_label.text = "🪙 %d" % total

func _on_gems_changed(total: int) -> void:
	_gems_label.text = "💎 %d" % total

func _on_lives_changed(lives: int) -> void:
	var full: int = clampi(lives, 0, GameManager.MAX_LIVES)
	_hearts_label.text = "❤".repeat(full) + "🖤".repeat(GameManager.MAX_LIVES - full)

func _on_objectives_changed(coins: int, target: int, secret_found: bool) -> void:
	var target_text := "Colete %d/%d moedas" % [coins, target] if target > 0 else "Colete moedas: %d" % coins
	var secret_text := "Estrela secreta: %s" % ("encontrada ✓" if secret_found else "não encontrada")
	_objectives_label.text = "%s   •   %s   •   Chegue ao final" % [target_text, secret_text]

## --- Fim de fase ---

func _on_goal_reached() -> void:
	if _paused_or_ended:
		return
	_paused_or_ended = true
	var stars := GameManager.finish_level_success()
	_show_victory(stars)

func _on_player_died() -> void:
	if _paused_or_ended:
		return
	_paused_or_ended = true
	_show_defeat()

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]

func _find_next_level_id() -> String:
	var levels: Array = GameManager.get_world(_world_id).get("levels", [])
	for i in range(levels.size()):
		if levels[i]["id"] == _level_id and i + 1 < levels.size():
			return levels[i + 1]["id"]
	return ""

func _go_to(screen_name: String, params: Dictionary = {}) -> void:
	get_tree().paused = false
	SceneRouter.go_to(screen_name, params)

## --- Overlays (pausa / vitória / derrota) ---

func _build_overlay() -> CenterContainer:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(center)
	_overlay_nodes = [dim, center]
	return center

func _clear_overlay() -> void:
	for n in _overlay_nodes:
		if is_instance_valid(n):
			n.queue_free()
	_overlay_nodes = []

func _show_pause() -> void:
	if _paused_or_ended:
		return
	_paused_or_ended = true
	get_tree().paused = true

	var center := _build_overlay()
	var panel := make_panel(Color(0.1, 0.12, 0.22, 0.98))
	panel.custom_minimum_size = Vector2(380, 360)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	box.add_child(make_label("PAUSADO", 28, COLOR_ACCENT))
	box.add_child(spacer(6))

	var resume_btn := make_button("▶ Continuar", COLOR_SUCCESS, Vector2(240, 58))
	resume_btn.pressed.connect(_resume)
	box.add_child(resume_btn)

	var restart_btn := make_button("🔄 Reiniciar fase", COLOR_PRIMARY, Vector2(240, 58))
	restart_btn.pressed.connect(func(): _go_to("game", {"world_id": _world_id, "level_id": _level_id}))
	box.add_child(restart_btn)

	var menu_btn := make_button("🏠 Menu", Color(1, 1, 1, 0.12), Vector2(240, 58))
	menu_btn.pressed.connect(func(): _go_to("main_menu"))
	box.add_child(menu_btn)

	center.add_child(panel)

func _resume() -> void:
	_clear_overlay()
	get_tree().paused = false
	_paused_or_ended = false

func _show_victory(stars: int) -> void:
	get_tree().paused = true
	var center := _build_overlay()
	var panel := make_panel(Color(0.08, 0.16, 0.12, 0.98))
	panel.custom_minimum_size = Vector2(420, 440)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	box.add_child(make_label("FASE CONCLUÍDA!", 28, COLOR_SUCCESS))
	box.add_child(make_label("⭐".repeat(stars) + "☆".repeat(3 - stars), 34, COLOR_ACCENT))
	box.add_child(make_label("🪙 Moedas: %d" % GameManager.session_coins, 18, COLOR_TEXT))
	box.add_child(make_label("⏱ Tempo: %s" % _format_time(_elapsed), 18, COLOR_TEXT))
	box.add_child(spacer(10))

	var next_level_id := _find_next_level_id()
	if next_level_id != "":
		var next_btn := make_button("▶ Próxima fase", COLOR_SUCCESS, Vector2(260, 58))
		next_btn.pressed.connect(func(): _go_to("game", {"world_id": _world_id, "level_id": next_level_id}))
		box.add_child(next_btn)

	var retry_btn := make_button("🔄 Repetir", COLOR_PRIMARY, Vector2(260, 58))
	retry_btn.pressed.connect(func(): _go_to("game", {"world_id": _world_id, "level_id": _level_id}))
	box.add_child(retry_btn)

	var map_btn := make_button("🏠 Mapa", Color(1, 1, 1, 0.12), Vector2(260, 58))
	map_btn.pressed.connect(func(): _go_to("level_map", {"world_id": _world_id}))
	box.add_child(map_btn)

	center.add_child(panel)

func _show_defeat() -> void:
	get_tree().paused = true
	var center := _build_overlay()
	var panel := make_panel(Color(0.2, 0.08, 0.08, 0.98))
	panel.custom_minimum_size = Vector2(380, 320)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	box.add_child(make_label("VOCÊ PERDEU!", 28, COLOR_DANGER))
	box.add_child(make_label("😥", 48))
	box.add_child(spacer(6))

	var retry_btn := make_button("🔄 Tentar novamente", COLOR_PRIMARY, Vector2(260, 58))
	retry_btn.pressed.connect(func(): _go_to("game", {"world_id": _world_id, "level_id": _level_id}))
	box.add_child(retry_btn)

	var map_btn := make_button("🏠 Voltar ao mapa", Color(1, 1, 1, 0.12), Vector2(260, 58))
	map_btn.pressed.connect(func(): _go_to("level_map", {"world_id": _world_id}))
	box.add_child(map_btn)

	center.add_child(panel)
