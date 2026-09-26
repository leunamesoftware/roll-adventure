extends Node
## Persistência do progresso do jogador em user://save_data.json.
## Único responsável por ler/escrever o arquivo de save.

const SAVE_PATH := "user://save_data.json"
const SAVE_VERSION := 1

var data: Dictionary = {}

func _ready() -> void:
	load_data()

func _default_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"coins_total": 0,
		"gems_total": 0,
		"powers": {"double_jump": false},
		"worlds": {
			"floresta": {"unlocked": true, "levels": {}},
			"cidade": {"unlocked": false, "levels": {}},
			"deserto": {"unlocked": false, "levels": {}},
			"gelo": {"unlocked": false, "levels": {}},
			"vulcao": {"unlocked": false, "levels": {}},
		},
		"settings": {"music_volume": 0.8, "sfx_volume": 1.0},
		"achievements": {},
		"purchases": {"remove_ads": false},
	}

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		data = _default_data()
		save_data()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		data = _default_data()
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: save corrompido, recriando.")
		data = _default_data()
		save_data()
		return
	data = parsed
	_ensure_defaults()

func _ensure_defaults() -> void:
	var defaults := _default_data()
	for key in defaults.keys():
		if not data.has(key):
			data[key] = defaults[key]
	for world_id in defaults["worlds"].keys():
		if not data["worlds"].has(world_id):
			data["worlds"][world_id] = defaults["worlds"][world_id]

func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: não foi possível salvar em %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func is_world_unlocked(world_id: String) -> bool:
	return data["worlds"].get(world_id, {}).get("unlocked", false)

func unlock_world(world_id: String) -> void:
	if not data["worlds"].has(world_id):
		data["worlds"][world_id] = {"unlocked": true, "levels": {}}
	else:
		data["worlds"][world_id]["unlocked"] = true
	save_data()

func get_level_progress(world_id: String, level_id: String) -> Dictionary:
	var world: Dictionary = data["worlds"].get(world_id, {})
	var levels: Dictionary = world.get("levels", {})
	return levels.get(level_id, {"stars": 0, "best_time": null, "completed": false})

func set_level_progress(world_id: String, level_id: String, stars: int, time_seconds: float, coins: int) -> void:
	if not data["worlds"].has(world_id):
		data["worlds"][world_id] = {"unlocked": true, "levels": {}}
	var world: Dictionary = data["worlds"][world_id]
	if not world.has("levels"):
		world["levels"] = {}
	var current: Dictionary = world["levels"].get(level_id, {"stars": 0, "best_time": null, "completed": false, "best_coins": 0})
	current["stars"] = max(int(current.get("stars", 0)), stars)
	current["completed"] = true
	if current.get("best_time") == null or time_seconds < float(current["best_time"]):
		current["best_time"] = time_seconds
	current["best_coins"] = max(int(current.get("best_coins", 0)), coins)
	world["levels"][level_id] = current
	save_data()

func total_stars_in_world(world_id: String) -> int:
	var world: Dictionary = data["worlds"].get(world_id, {})
	var levels: Dictionary = world.get("levels", {})
	var total := 0
	for level_id in levels.keys():
		total += int(levels[level_id].get("stars", 0))
	return total

func total_stars_all_worlds() -> int:
	var total := 0
	for world_id in data["worlds"].keys():
		total += total_stars_in_world(world_id)
	return total

func add_coins(amount: int) -> void:
	data["coins_total"] = int(data.get("coins_total", 0)) + amount
	save_data()

func spend_coins(amount: int) -> bool:
	if int(data.get("coins_total", 0)) < amount:
		return false
	data["coins_total"] = int(data["coins_total"]) - amount
	save_data()
	return true

func add_gems(amount: int) -> void:
	data["gems_total"] = int(data.get("gems_total", 0)) + amount
	save_data()

func spend_gems(amount: int) -> bool:
	if int(data.get("gems_total", 0)) < amount:
		return false
	data["gems_total"] = int(data["gems_total"]) - amount
	save_data()
	return true

func unlock_power(power_id: String) -> void:
	if not data.has("powers"):
		data["powers"] = {}
	data["powers"][power_id] = true
	save_data()

func has_power(power_id: String) -> bool:
	return bool(data.get("powers", {}).get(power_id, false))

func get_setting(key: String, default_value):
	return data.get("settings", {}).get(key, default_value)

func set_setting(key: String, value) -> void:
	if not data.has("settings"):
		data["settings"] = {}
	data["settings"][key] = value
	save_data()
