extends Node
## Orquestra o estado de jogo em tempo de execução (sessão da fase atual) e o catálogo
## estático de mundos/fases carregado de res://data/worlds.json. O progresso persistente
## (estrelas, moedas, gemas, poderes) vive em SaveManager.

signal coins_changed(total: int)
signal gems_changed(total: int)
signal lives_changed(lives: int)
signal objective_progress_changed(coins: int, coin_target: int, secret_found: bool)
signal level_completed(world_id: String, level_id: String, stars: int)

const WORLD_CATALOG_PATH := "res://data/worlds.json"
const MAX_LIVES := 3

var world_catalog: Array = []

var current_world_id: String = ""
var current_level_id: String = ""
var current_coin_target: int = 0

var session_coins: int = 0
var session_secret_star_found: bool = false
var lives: int = MAX_LIVES
var double_jump_unlocked: bool = false

func _ready() -> void:
	_setup_input_actions()
	_load_catalog()
	double_jump_unlocked = SaveManager.has_power("double_jump")

func _setup_input_actions() -> void:
	_add_action("move_left", [KEY_LEFT, KEY_A])
	_add_action("move_right", [KEY_RIGHT, KEY_D])
	_add_action("jump", [KEY_SPACE, KEY_UP, KEY_W])
	_add_action("pause_game", [KEY_ESCAPE, KEY_P])

func _add_action(action_name: String, keys: Array) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name)
	for key in keys:
		var event := InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action_name, event)

func _load_catalog() -> void:
	if not FileAccess.file_exists(WORLD_CATALOG_PATH):
		push_error("GameManager: catálogo de mundos não encontrado em %s" % WORLD_CATALOG_PATH)
		return
	var file := FileAccess.open(WORLD_CATALOG_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("worlds"):
		world_catalog = parsed["worlds"]

## --- Consulta ao catálogo (mesclado com progresso salvo) ---

func get_worlds() -> Array:
	var result: Array = []
	for world in world_catalog:
		var world_id: String = world["id"]
		var entry: Dictionary = world.duplicate(true)
		entry["unlocked"] = SaveManager.is_world_unlocked(world_id)
		entry["stars_earned"] = SaveManager.total_stars_in_world(world_id)
		entry["stars_total"] = world["levels"].size() * 3
		result.append(entry)
	return result

func get_world(world_id: String) -> Dictionary:
	for world in world_catalog:
		if world["id"] == world_id:
			return world
	return {}

func get_levels(world_id: String) -> Array:
	var world := get_world(world_id)
	var levels: Array = world.get("levels", [])
	var result: Array = []
	var previous_completed := true
	for level in levels:
		var entry: Dictionary = level.duplicate(true)
		var progress := SaveManager.get_level_progress(world_id, level["id"])
		entry["stars"] = progress.get("stars", 0)
		entry["completed"] = progress.get("completed", false)
		entry["best_time"] = progress.get("best_time")
		entry["unlocked"] = previous_completed
		previous_completed = entry["completed"]
		result.append(entry)
	return result

func get_level_entry(world_id: String, level_id: String) -> Dictionary:
	for level in get_world(world_id).get("levels", []):
		if level["id"] == level_id:
			return level
	return {}

func get_level_data_path(world_id: String, level_id: String) -> String:
	return String(get_level_entry(world_id, level_id).get("scene_data", ""))

## --- Sessão de jogo ---

func start_level(world_id: String, level_id: String) -> void:
	current_world_id = world_id
	current_level_id = level_id
	var level_entry := get_level_entry(world_id, level_id)
	current_coin_target = int(level_entry.get("coin_target", 0))
	session_coins = 0
	session_secret_star_found = false
	lives = MAX_LIVES
	coins_changed.emit(session_coins)
	lives_changed.emit(lives)
	objective_progress_changed.emit(session_coins, current_coin_target, session_secret_star_found)

func collect_coin(amount: int = 1) -> void:
	session_coins += amount
	coins_changed.emit(session_coins)
	objective_progress_changed.emit(session_coins, current_coin_target, session_secret_star_found)

func collect_gem(amount: int = 1) -> void:
	SaveManager.add_gems(amount)
	gems_changed.emit(SaveManager.data.get("gems_total", 0))

func find_secret_star() -> void:
	if session_secret_star_found:
		return
	session_secret_star_found = true
	objective_progress_changed.emit(session_coins, current_coin_target, session_secret_star_found)

func lose_life() -> bool:
	lives -= 1
	lives_changed.emit(lives)
	return lives <= 0

## Chamado quando o jogador alcança a bandeira de chegada.
## Estrelas = chegar ao final (sempre) + bater meta de moedas + achar estrela secreta.
func finish_level_success() -> int:
	var stars := 1
	if current_coin_target <= 0 or session_coins >= current_coin_target:
		stars += 1
	if session_secret_star_found:
		stars += 1
	SaveManager.set_level_progress(current_world_id, current_level_id, stars, 0.0, session_coins)
	SaveManager.add_coins(session_coins)
	_maybe_unlock_next_world()
	if current_world_id == "floresta" and current_level_id == "fase_1" and not double_jump_unlocked:
		double_jump_unlocked = true
		SaveManager.unlock_power("double_jump")
	level_completed.emit(current_world_id, current_level_id, stars)
	return stars

func _maybe_unlock_next_world() -> void:
	var order_sorted: Array = world_catalog.duplicate()
	order_sorted.sort_custom(func(a, b): return a["order"] < b["order"])
	for i in range(order_sorted.size() - 1):
		if order_sorted[i]["id"] == current_world_id:
			var next_world_id: String = order_sorted[i + 1]["id"]
			if SaveManager.total_stars_in_world(current_world_id) >= 1:
				SaveManager.unlock_world(next_world_id)
			break
