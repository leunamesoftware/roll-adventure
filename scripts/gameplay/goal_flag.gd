extends Area2D
class_name GoalFlag
## Bandeira de chegada original. Ao ser tocada pelo jogador, emite "reached" para o
## GameScreen concluir a fase.

signal reached

const POLE_COLOR := Color(0.55, 0.55, 0.6)
const FLAG_COLOR := Color(1.0, 0.85, 0.2)
const HEIGHT := 140.0

var _triggered: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = CollisionLayers.PLAYER
	monitorable = false
	var shape := RectangleShape2D.new()
	shape.size = Vector2(56, HEIGHT)
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = Vector2(0, -HEIGHT / 2.0)
	add_child(cs)
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if _triggered:
		return
	if body is Player:
		_triggered = true
		reached.emit()

func _draw() -> void:
	draw_line(Vector2.ZERO, Vector2(0, -HEIGHT), POLE_COLOR, 6.0)
	var flag_points := PackedVector2Array([
		Vector2(0, -HEIGHT),
		Vector2(46, -HEIGHT + 16),
		Vector2(0, -HEIGHT + 32),
	])
	draw_colored_polygon(flag_points, FLAG_COLOR)
