extends Area2D
class_name ObstacleSpikes
## Fileira de espinhos originais (triângulos desenhados via _draw()). Machuca o jogador ao tocar.

@export var width: float = 96.0
@export var spike_count: int = 3
@export var color: Color = Color(0.75, 0.16, 0.16)

func _ready() -> void:
	collision_layer = 0
	collision_mask = CollisionLayers.PLAYER
	monitorable = false
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 28)
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = Vector2(0, -8)
	add_child(cs)
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.take_hit()

func _draw() -> void:
	var step: float = width / float(spike_count)
	for i in range(spike_count):
		var base_x: float = -width / 2.0 + step * i
		var points := PackedVector2Array([
			Vector2(base_x, 14),
			Vector2(base_x + step * 0.5, -22),
			Vector2(base_x + step, 14),
		])
		draw_colored_polygon(points, color)
