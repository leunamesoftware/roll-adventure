extends AnimatableBody2D
class_name MovingPlatform
## Plataforma móvel original: vai e volta entre a posição inicial e start + travel.
## AnimatableBody2D com sync_to_physics para carregar o jogador corretamente.

@export var size: Vector2 = Vector2(140, 32)
@export var travel: Vector2 = Vector2(220, 0)
@export var speed: float = 90.0
@export var body_color: Color = Color(0.42, 0.28, 0.16)
@export var top_color: Color = Color(0.29, 0.68, 0.31)

var _start_pos: Vector2
var _t: float = 0.0
var _direction: int = 1

func _ready() -> void:
	collision_layer = CollisionLayers.WORLD
	collision_mask = 0
	sync_to_physics = true
	var shape := RectangleShape2D.new()
	shape.size = size
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)
	_start_pos = position
	queue_redraw()

func _physics_process(delta: float) -> void:
	var distance := travel.length()
	if distance <= 0.0:
		return
	var full_time: float = distance / max(speed, 1.0)
	_t += (delta / full_time) * _direction
	if _t >= 1.0:
		_t = 1.0
		_direction = -1
	elif _t <= 0.0:
		_t = 0.0
		_direction = 1
	position = _start_pos + travel * _t

func _draw() -> void:
	var half := size / 2.0
	draw_rect(Rect2(-half, size), body_color, true)
	var top_strip_height: float = min(14.0, size.y * 0.3)
	draw_rect(Rect2(Vector2(-half.x, -half.y), Vector2(size.x, top_strip_height)), top_color, true)
