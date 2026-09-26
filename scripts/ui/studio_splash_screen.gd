extends ScreenBase
class_name StudioSplashScreen
## Tela de abertura do estúdio ("Um jogo LeuName Softwares"), exibida uma vez antes
## do menu principal. Toque na tela pula direto para o menu.

const DISPLAY_TIME := 2.2
const HERO_IMAGE := preload("res://assets/icons/icon_512.png")

func _ready() -> void:
	add_background_gradient()
	mouse_filter = Control.MOUSE_FILTER_STOP

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 14)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var hero := TextureRect.new()
	hero.texture = HERO_IMAGE
	hero.custom_minimum_size = Vector2(260, 260)
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.add_child(hero)

	root.add_child(make_label("LEUNAME SOFTWARES", 26, COLOR_TEXT))
	root.add_child(make_label("apresenta", 16, COLOR_TEXT_DIM))

	var timer := get_tree().create_timer(DISPLAY_TIME)
	timer.timeout.connect(_go_to_menu)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			_go_to_menu()

var _left := false

func _go_to_menu() -> void:
	if _left:
		return
	_left = true
	SceneRouter.go_to("main_menu")
