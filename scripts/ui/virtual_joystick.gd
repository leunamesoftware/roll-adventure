extends Control
class_name VirtualJoystick
## Joystick virtual circular original para controlar o eixo horizontal do jogador
## (arrastar o dedo dentro da base move a bolinha). Suporta touch (multitouch via
## índice) e mouse (para testar no editor/desktop).

signal direction_changed(value: float)

const BASE_RADIUS := 70.0
const KNOB_RADIUS := 34.0
const BASE_COLOR := Color(1, 1, 1, 0.18)
const KNOB_COLOR := Color(1, 1, 1, 0.55)

var _touch_index: int = -2
var _knob_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(BASE_RADIUS, BASE_RADIUS) * 2.0
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -2:
			_touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_release()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)
	elif event is InputEventMouseButton:
		if event.pressed and _touch_index == -2:
			_touch_index = -1
			_update_knob(event.position)
		elif not event.pressed and _touch_index == -1:
			_release()
	elif event is InputEventMouseMotion and _touch_index == -1:
		_update_knob(event.position)

func _release() -> void:
	_touch_index = -2
	_knob_offset = Vector2.ZERO
	direction_changed.emit(0.0)
	queue_redraw()

func _update_knob(pos: Vector2) -> void:
	var center := size / 2.0
	var offset := pos - center
	if offset.length() > BASE_RADIUS:
		offset = offset.normalized() * BASE_RADIUS
	_knob_offset = offset
	direction_changed.emit(clamp(offset.x / BASE_RADIUS, -1.0, 1.0))
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	draw_circle(center, BASE_RADIUS, BASE_COLOR)
	draw_circle(center + _knob_offset, KNOB_RADIUS, KNOB_COLOR)
