extends CharacterBody2D
class_name EnemyPatrol
## Inimigo terrestre original que anda de um lado para o outro. Um único script cobre
## algumas variações visuais (style) para dar diversidade sem duplicar comportamento.
## Pisar em cima derrota o inimigo; tocar pela lateral machuca o jogador.

enum Style { SPIKE_BALL, CRAWLER, SHELLED }

@export var style: Style = Style.SPIKE_BALL
@export var patrol_distance: float = 140.0
@export var speed: float = 90.0

const RADIUS := 24.0
const GRAVITY := 1200.0

var _start_x: float = 0.0
var _direction: int = 1
var _alive: bool = true
var _hurt_area: Area2D

func _ready() -> void:
	collision_layer = CollisionLayers.ENEMY
	collision_mask = CollisionLayers.WORLD
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)

	_hurt_area = Area2D.new()
	_hurt_area.collision_layer = 0
	_hurt_area.collision_mask = CollisionLayers.PLAYER
	_hurt_area.monitorable = false
	var hurt_shape := CircleShape2D.new()
	hurt_shape.radius = RADIUS
	var hurt_cs := CollisionShape2D.new()
	hurt_cs.shape = hurt_shape
	_hurt_area.add_child(hurt_cs)
	add_child(_hurt_area)
	_hurt_area.body_entered.connect(_on_player_touched)

	_start_x = position.x

func _physics_process(delta: float) -> void:
	if not _alive:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	velocity.x = _direction * speed
	move_and_slide()
	if is_on_wall() or absf(position.x - _start_x) >= patrol_distance:
		_direction *= -1
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
	collision_layer = 0
	collision_mask = 0
	_hurt_area.set_deferred("monitoring", false)
	AudioManager.play_sfx(null)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 0.15), 0.15)
	tween.tween_callback(queue_free)

func _draw() -> void:
	match style:
		Style.SPIKE_BALL:
			_draw_spike_ball()
		Style.CRAWLER:
			_draw_crawler()
		Style.SHELLED:
			_draw_shelled()

func _draw_spike_ball() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.82, 0.22, 0.22))
	var spike_count := 8
	for i in range(spike_count):
		var angle: float = TAU / spike_count * i
		var dir := Vector2(cos(angle), sin(angle))
		draw_line(dir * RADIUS * 0.7, dir * RADIUS * 1.4, Color(0.95, 0.95, 0.95), 4.0)
	_draw_angry_eyes()

func _draw_crawler() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.55, 0.36, 0.2))
	draw_rect(Rect2(Vector2(-RADIUS * 0.9, RADIUS * 0.5), Vector2(RADIUS * 0.5, RADIUS * 0.6)), Color(0.35, 0.22, 0.1), true)
	draw_rect(Rect2(Vector2(RADIUS * 0.4, RADIUS * 0.5), Vector2(RADIUS * 0.5, RADIUS * 0.6)), Color(0.35, 0.22, 0.1), true)
	_draw_angry_eyes()

func _draw_shelled() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color(0.35, 0.65, 0.3))
	draw_arc(Vector2.ZERO, RADIUS * 0.95, PI, TAU, 20, Color(0.8, 0.25, 0.25), RADIUS * 0.9)
	_draw_angry_eyes()

func _draw_angry_eyes() -> void:
	var eye_gap := Vector2(RADIUS * 0.35, 0)
	var eye_y := -RADIUS * 0.1
	draw_circle(Vector2(-eye_gap.x, eye_y), RADIUS * 0.18, Color.WHITE)
	draw_circle(Vector2(eye_gap.x, eye_y), RADIUS * 0.18, Color.WHITE)
	draw_circle(Vector2(-eye_gap.x, eye_y), RADIUS * 0.08, Color.BLACK)
	draw_circle(Vector2(eye_gap.x, eye_y), RADIUS * 0.08, Color.BLACK)
