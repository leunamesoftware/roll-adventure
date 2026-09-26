extends CharacterBody2D
class_name Player
## Personagem principal (TRIXO). Usa a arte oficial do personagem (assets/sprites/
## trixo_run.png) como sprite único por enquanto — animação por quadros (parado,
## correndo, pulando) fica para uma próxima etapa. Movimento lateral + pulo + pulo
## duplo desbloqueável.

signal died
signal coin_collected(total: int)

const RADIUS := 28.0 ## raio efetivo usado para cálculos de gameplay (ex.: pisão em inimigo)
const SPRITE_HEIGHT := 84.0 ## altura visual do personagem em pixels
const SPEED := 320.0
const ACCELERATION := 2400.0
const FRICTION := 2600.0
const JUMP_VELOCITY := -900.0
const DOUBLE_JUMP_VELOCITY := -760.0
const MAX_FALL_SPEED := 1400.0
const INVULNERABLE_TIME := 1.2

const SPRITE_TEXTURE := preload("res://assets/sprites/trixo_run.png")

var _sprite: Sprite2D

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

	var shape := CapsuleShape2D.new()
	shape.radius = 22.0
	shape.height = SPRITE_HEIGHT - shape.radius * 2.0
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)

	_sprite = Sprite2D.new()
	_sprite.texture = SPRITE_TEXTURE
	var tex_size := SPRITE_TEXTURE.get_size()
	var sprite_scale: float = SPRITE_HEIGHT / tex_size.y
	_sprite.scale = Vector2(sprite_scale, sprite_scale)
	add_child(_sprite)

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

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = min(velocity.y + _gravity * delta, MAX_FALL_SPEED)

func _handle_horizontal(delta: float) -> void:
	var target_speed := _direction_input * SPEED
	if _direction_input != 0.0:
		_facing = sign(_direction_input)
		_sprite.flip_h = _facing > 0.0  ## arte original olha para a esquerda
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
