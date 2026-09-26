extends PickupBase
class_name Gem

@export var value: int = 1
const COLOR := Color(0.3, 0.85, 0.95)
const COLOR_DARK := Color(0.1, 0.5, 0.65)

func _on_collected(_player: Player) -> void:
	GameManager.collect_gem(value)
	AudioManager.play_sfx(null)

func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(0, -radius), Vector2(radius * 0.8, -radius * 0.2),
		Vector2(radius * 0.5, radius), Vector2(-radius * 0.5, radius),
		Vector2(-radius * 0.8, -radius * 0.2),
	])
	draw_colored_polygon(points, COLOR)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, COLOR_DARK, 2.0, true)
