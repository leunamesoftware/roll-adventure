extends StaticBody2D
class_name Platform
## Plataforma sólida original: retângulo com faixa "de grama" no topo, desenhada via _draw().

@export var size: Vector2 = Vector2(160, 40)
@export var top_color: Color = Color(0.29, 0.68, 0.31)
@export var body_color: Color = Color(0.42, 0.28, 0.16)

func _ready() -> void:
	collision_layer = CollisionLayers.WORLD
	collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = size
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)
	queue_redraw()

func _draw() -> void:
	var half := size / 2.0
	draw_rect(Rect2(-half, size), body_color, true)
	var top_strip_height: float = min(14.0, size.y * 0.3)
	draw_rect(Rect2(Vector2(-half.x, -half.y), Vector2(size.x, top_strip_height)), top_color, true)
