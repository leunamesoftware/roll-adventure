extends Node2D
class_name SwingingSpikeBall
## Armadilha giratória original: bola de espinhos pendurada por uma corrente que balança
## como um pêndulo. Machuca o jogador ao encostar.

@export var chain_length: float = 140.0
@export var swing_amplitude_deg: float = 55.0
@export var swing_speed: float = 1.6
const BALL_RADIUS := 22.0
const BALL_COLOR := Color(0.2, 0.2, 0.24)
const SPIKE_COLOR := Color(0.55, 0.55, 0.6)
const CHAIN_COLOR := Color(0.4, 0.4, 0.45)

var _time: float = 0.0
var _hurt_area: Area2D

func _ready() -> void:
	_time = randf() * TAU
	_hurt_area = Area2D.new()
	_hurt_area.collision_layer = 0
	_hurt_area.collision_mask = CollisionLayers.PLAYER
	_hurt_area.monitorable = false
	var shape := CircleShape2D.new()
	shape.radius = BALL_RADIUS
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = Vector2(0, chain_length)
	_hurt_area.add_child(cs)
	add_child(_hurt_area)
	_hurt_area.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_time += delta * swing_speed
	rotation = deg_to_rad(swing_amplitude_deg) * sin(_time)
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.take_hit()

func _draw() -> void:
	var ball_pos := Vector2(0, chain_length)
	draw_line(Vector2.ZERO, ball_pos, CHAIN_COLOR, 5.0)
	draw_circle(ball_pos, BALL_RADIUS, BALL_COLOR)
	var spike_count := 8
	for i in range(spike_count):
		var angle: float = TAU / spike_count * i
		var dir := Vector2(cos(angle), sin(angle))
		draw_line(ball_pos + dir * BALL_RADIUS * 0.7, ball_pos + dir * BALL_RADIUS * 1.5, SPIKE_COLOR, 4.0)
