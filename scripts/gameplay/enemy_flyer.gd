extends Node2D
class_name EnemyFlyer
## Inimigo voador original (estilo inseto), voa em uma trajetória senoidal indo e voltando.
## Mesmo comportamento de pisar-para-derrotar / tocar-machuca do inimigo terrestre.

const RADIUS := 20.0
const BODY_COLOR := Color(1.0, 0.78, 0.15)
const STRIPE_COLOR := Color(0.15, 0.13, 0.1)
const WING_COLOR := Color(1.0, 1.0, 1.0, 0.7)

@export var patrol_distance: float = 180.0
@export var speed: float = 70.0
@export var bob_height: float = 24.0

var _start_pos: Vector2
var _t: float = 0.0
var _direction: int = 1
var _alive: bool = true
var _hurt_area: Area2D
var _wing_time: float = 0.0

func _ready() -> void:
	_start_pos = position
	_hurt_area = Area2D.new()
	_hurt_area.collision_layer = 0
	_hurt_area.collision_mask = CollisionLayers.PLAYER
	_hurt_area.monitorable = false
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var cs := CollisionShape2D.new()
	cs.shape = shape
	_hurt_area.add_child(cs)
	add_child(_hurt_area)
	_hurt_area.body_entered.connect(_on_player_touched)

func _process(delta: float) -> void:
	if not _alive:
		return
	_wing_time += delta * 20.0
	var full_time: float = (patrol_distance * 2.0) / max(speed, 1.0)
	_t += (delta / full_time) * _direction
	if _t >= 1.0:
		_t = 1.0
		_direction = -1
	elif _t <= 0.0:
		_t = 0.0
		_direction = 1
	var x_offset: float = lerp(-patrol_distance, patrol_distance, _t)
	var y_offset: float = sin(_t * PI * 4.0) * bob_height
	position = _start_pos + Vector2(x_offset, y_offset)
	queue_redraw()

func _on_player_touched(body: Node) -> void:
	if not _alive or not (body is Player):
		return
	var player: Player = body
	var stomped: bool = player.velocity.y > 0.0 and player.global_position.y < global_position.y - RADIUS * 0.3
	if stomped:
		defeat(player)
	else:
		player.take_hit()

func defeat(player: Player) -> void:
	_alive = false
	player.velocity.y = -600.0
	_hurt_area.set_deferred("monitoring", false)
	AudioManager.play_sfx(null)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.15, 0.15), 0.15)
	tween.tween_callback(queue_free)

func _draw() -> void:
	var wing_lift: float = sin(_wing_time) * 6.0
	draw_colored_polygon(PackedVector2Array([
		Vector2(-4, -6), Vector2(-RADIUS * 1.3, -RADIUS - wing_lift), Vector2(-RADIUS * 0.4, -4),
	]), WING_COLOR)
	draw_colored_polygon(PackedVector2Array([
		Vector2(4, -6), Vector2(RADIUS * 1.3, -RADIUS - wing_lift), Vector2(RADIUS * 0.4, -4),
	]), WING_COLOR)
	draw_circle(Vector2.ZERO, RADIUS, BODY_COLOR)
	for i in range(3):
		var stripe_x: float = -RADIUS * 0.5 + i * RADIUS * 0.5
		draw_rect(Rect2(Vector2(stripe_x, -RADIUS), Vector2(RADIUS * 0.28, RADIUS * 2.0)), STRIPE_COLOR, true)
	draw_circle(Vector2(-RADIUS * 0.35, -RADIUS * 0.1), RADIUS * 0.16, Color.WHITE)
	draw_circle(Vector2(RADIUS * 0.35, -RADIUS * 0.1), RADIUS * 0.16, Color.WHITE)
	draw_circle(Vector2(-RADIUS * 0.35, -RADIUS * 0.1), RADIUS * 0.07, Color.BLACK)
	draw_circle(Vector2(RADIUS * 0.35, -RADIUS * 0.1), RADIUS * 0.07, Color.BLACK)
