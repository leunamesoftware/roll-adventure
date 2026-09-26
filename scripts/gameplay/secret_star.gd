extends PickupBase
class_name SecretStar
## Colecionável opcional escondido na fase. Completa um dos objetivos ("estrela secreta").

const COLOR := Color(1.0, 0.9, 0.3)
const COLOR_DARK := Color(0.85, 0.6, 0.1)

func _on_collected(_player: Player) -> void:
	GameManager.find_secret_star()
	AudioManager.play_sfx(null)

func _draw() -> void:
	var points := PackedVector2Array()
	var outer: float = radius * 1.4
	var inner: float = radius * 0.6
	for i in range(10):
		var r: float = outer if i % 2 == 0 else inner
		var angle: float = -PI / 2.0 + i * PI / 5.0
		points.append(Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, COLOR)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, COLOR_DARK, 2.0, true)
