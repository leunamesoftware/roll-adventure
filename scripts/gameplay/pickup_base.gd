extends Area2D
class_name PickupBase
## Base comum para coletáveis (moeda, gema, estrela secreta): flutua suavemente e some
## ao ser tocado pelo jogador. Subclasses sobrescrevem _on_collected() e _draw().

@export var radius: float = 14.0

var _bob_time: float = 0.0
var _base_y: float = 0.0
var _collected: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = CollisionLayers.PLAYER
	monitorable = false
	var shape := CircleShape2D.new()
	shape.radius = radius
	var cs := CollisionShape2D.new()
	cs.shape = shape
	add_child(cs)
	body_entered.connect(_on_body_entered)
	_base_y = position.y
	_bob_time = randf() * TAU

func _process(delta: float) -> void:
	if _collected:
		return
	_bob_time += delta * 3.0
	position.y = _base_y + sin(_bob_time) * 4.0
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if body is Player:
		_collected = true
		_on_collected(body)
		queue_free()

func _on_collected(_player: Player) -> void:
	pass
