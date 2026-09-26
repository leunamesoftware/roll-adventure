extends CharacterBody2D
class_name Player
## Personagem principal original: uma bolinha com rosto, desenhada via _draw() (sem
## dependência de arte externa). Movimento lateral + pulo + pulo duplo desbloqueável.

signal died
signal coin_collected(total: int)

const RADIUS := 28.0
const SPEED := 320.0
const ACCELERATION := 2400.0
const FRICTION := 2600.0
const JUMP_VELOCITY := -900.0
const DOUBLE_JUMP_VELOCITY := -760.0
const MAX_FALL_SPEED := 1400.0
const INVULNERABLE_TIME := 1.2

const BODY_COLOR := Color(0.18, 0.56, 0.94)
const BODY_COLOR_DARK := Color(0.11, 0.37, 0.74)
const FACE_COLOR := Color(0.09, 0.14, 0.25)

var _gravity: float = 980.0
var _direction_input: float = 0.0
var _jump_buffered: bool = false
var _can_double_jump: bool = false
var _has_double_jumped: bool = false
var _invulnerable: bool = false
var _facing: float = 1.0
var _squash: float = 1.0
var _is_dead: bool = false

func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
	collision_layer = CollisionLayers.PLAYER
	collision_mask = CollisionLayers.WORLD
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)
	add_to_group("player")
	_can_double_jump = GameManager.double_jump_unlocked

func set_direction(dir: float) -> void:
	_direction_input = clamp(dir, -1.0, 1.0)

func request_jump() -> void:
	_jump_buffered = true

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_apply_gravity(delta)
	_handle_horizontal(delta)
	_handle_jump()
	move_and_slide()
	if is_on_floor():
		_has_double_jumped = false
	_update_squash(delta)
	queue_redraw()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = min(velocity.y + _gravity * delta, MAX_FALL_SPEED)

func _handle_horizontal(delta: float) -> void:
	var target_speed := _direction_input * SPEED
	if _direction_input != 0.0:
		_facing = sign(_direction_input)
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

func _handle_jump() -> void:
	if not _jump_buffered:
		return
	_jump_buffered = false
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		_squash = 1.35
		AudioManager.play_sfx(null)
	elif _can_double_jump and not _has_double_jumped:
		velocity.y = DOUBLE_JUMP_VELOCITY
		_has_double_jumped = true
		_squash = 1.35
		AudioManager.play_sfx(null)

func _update_squash(delta: float) -> void:
	_squash = move_toward(_squash, 1.0, delta * 3.0)
	scale = Vector2(2.0 - _squash, _squash)

func take_hit() -> void:
	if _invulnerable or _is_dead:
		return
	var game_over := GameManager.lose_life()
	AudioManager.play_sfx(null)
	_flash_invulnerable()
	if game_over:
		die()

func _flash_invulnerable() -> void:
	_invulnerable = true
	modulate.a = 0.5
	await get_tree().create_timer(INVULNERABLE_TIME).timeout
	if is_instance_valid(self):
		modulate.a = 1.0
		_invulnerable = false

func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	died.emit()

func collect_coin(amount: int = 1) -> void:
	GameManager.collect_coin(amount)
	coin_collected.emit(amount)

func enable_double_jump() -> void:
	_can_double_jump = true

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, BODY_COLOR)
	draw_arc(Vector2.ZERO, RADIUS - 2.0, PI, TAU, 32, BODY_COLOR_DARK, 4.0)
	var eye_offset := Vector2(RADIUS * 0.32 * _facing, -RADIUS * 0.05)
	var eye_gap := Vector2(RADIUS * 0.34, 0.0)
	draw_circle(eye_offset - eye_gap, RADIUS * 0.16, FACE_COLOR)
	draw_circle(eye_offset + eye_gap, RADIUS * 0.16, FACE_COLOR)
	_draw_smile(Vector2(0, RADIUS * 0.28))

func _draw_smile(center: Vector2) -> void:
	var points := PackedVector2Array()
	var width := RADIUS * 0.5
	var steps := 12
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var x: float = lerp(-width, width, t)
		var y := sin(t * PI) * RADIUS * 0.22
		points.append(center + Vector2(x, y))
	draw_polyline(points, FACE_COLOR, 4.0, true)
