extends PickupBase
class_name Coin

@export var value: int = 1
const COLOR := Color(1.0, 0.82, 0.2)
const COLOR_DARK := Color(0.82, 0.6, 0.05)

func _on_collected(player: Player) -> void:
	player.collect_coin(value)
	AudioManager.play_sfx(null)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, COLOR)
	draw_arc(Vector2.ZERO, radius - 2.0, 0, TAU, 24, COLOR_DARK, 2.0)
