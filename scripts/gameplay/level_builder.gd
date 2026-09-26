extends Node2D
class_name LevelBuilder
## Constrói uma fase inteira em tempo de execução a partir de um arquivo JSON de dados
## (res://data/levels/*.json). É isso que permite criar e ajustar fases sem precisar
## editar cenas no editor — basta escrever (ou gerar) um novo arquivo de dados.
## Ver docs/ARQUITETURA.md para o esquema completo do JSON de fase.

signal goal_reached
signal player_died

var background_color: Color = Color(0.55, 0.82, 0.96)
var level_size: Vector2 = Vector2(2400, 1080)
var player: Player

func build_from_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("LevelBuilder: não encontrou %s" % path)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("LevelBuilder: JSON inválido em %s" % path)
		return
	build_from_data(parsed)

func build_from_data(data: Dictionary) -> void:
	background_color = Color(data.get("background_color", "#8fd3f4"))
	level_size = Vector2(float(data.get("level_width", 2400)), float(data.get("level_height", 1080)))

	for p in data.get("platforms", []):
		_add_platform(p)
	for p in data.get("moving_platforms", []):
		_add_moving_platform(p)
	for s in data.get("spikes", []):
		_add_spikes(s)
	for s in data.get("swinging_spikes", []):
		_add_swinging_spike(s)
	for c in data.get("coins", []):
		_add_coin(c)
	for g in data.get("gems", []):
		_add_gem(g)
	if data.has("secret_star"):
		_add_secret_star(data["secret_star"])
	for e in data.get("enemies", []):
		_add_enemy(e)
	if data.has("goal"):
		_add_goal(data["goal"])

	var start: Array = data.get("player_start", [120, 600])
	player = Player.new()
	player.position = _pos(start)
	add_child(player)
	player.died.connect(func(): player_died.emit())
	queue_redraw()

func _pos(arr: Array) -> Vector2:
	return Vector2(float(arr[0]), float(arr[1]))

func _add_platform(p: Dictionary) -> void:
	var platform := Platform.new()
	platform.position = _pos(p["pos"])
	if p.has("size"):
		platform.size = _pos(p["size"])
	add_child(platform)

func _add_moving_platform(p: Dictionary) -> void:
	var platform := MovingPlatform.new()
	platform.position = _pos(p["pos"])
	if p.has("size"):
		platform.size = _pos(p["size"])
	if p.has("travel"):
		platform.travel = _pos(p["travel"])
	if p.has("speed"):
		platform.speed = float(p["speed"])
	add_child(platform)

func _add_spikes(s: Dictionary) -> void:
	var spikes := ObstacleSpikes.new()
	spikes.position = _pos(s["pos"])
	if s.has("width"):
		spikes.width = float(s["width"])
	if s.has("count"):
		spikes.spike_count = int(s["count"])
	add_child(spikes)

func _add_swinging_spike(s: Dictionary) -> void:
	var ball := SwingingSpikeBall.new()
	ball.position = _pos(s["pos"])
	if s.has("chain_length"):
		ball.chain_length = float(s["chain_length"])
	add_child(ball)

func _add_coin(c) -> void:
	var coin := Coin.new()
	if c is Array:
		coin.position = _pos(c)
	else:
		coin.position = _pos(c["pos"])
		if c.has("value"):
			coin.value = int(c["value"])
	add_child(coin)

func _add_gem(g) -> void:
	var gem := Gem.new()
	if g is Array:
		gem.position = _pos(g)
	else:
		gem.position = _pos(g["pos"])
	add_child(gem)

func _add_secret_star(s: Dictionary) -> void:
	var star := SecretStar.new()
	star.position = _pos(s["pos"])
	add_child(star)

func _add_enemy(e: Dictionary) -> void:
	var enemy_type: String = e.get("type", "patrol")
	if enemy_type == "flyer":
		var flyer := EnemyFlyer.new()
		flyer.position = _pos(e["pos"])
		if e.has("patrol_distance"):
			flyer.patrol_distance = float(e["patrol_distance"])
		if e.has("speed"):
			flyer.speed = float(e["speed"])
		add_child(flyer)
	else:
		var enemy := EnemyPatrol.new()
		enemy.position = _pos(e["pos"])
		if e.has("patrol_distance"):
			enemy.patrol_distance = float(e["patrol_distance"])
		if e.has("speed"):
			enemy.speed = float(e["speed"])
		match String(e.get("style", "spike_ball")):
			"crawler":
				enemy.style = EnemyPatrol.Style.CRAWLER
			"shelled":
				enemy.style = EnemyPatrol.Style.SHELLED
			_:
				enemy.style = EnemyPatrol.Style.SPIKE_BALL
		add_child(enemy)

func _add_goal(g: Dictionary) -> void:
	var goal := GoalFlag.new()
	goal.position = _pos(g["pos"])
	goal.reached.connect(func(): goal_reached.emit())
	add_child(goal)

const BACKGROUND_PADDING := 600.0 ## garante que o fundo cubra a tela mesmo em celulares
## com proporção bem diferente de 16:9 (a câmera pode mostrar área além do
## tamanho "oficial" da fase, principalmente na vertical).

func _draw() -> void:
	var pad := Vector2(BACKGROUND_PADDING, BACKGROUND_PADDING)
	draw_rect(Rect2(-pad, level_size + pad * 2.0), background_color, true)
