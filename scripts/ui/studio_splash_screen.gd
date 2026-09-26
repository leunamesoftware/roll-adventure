extends ScreenBase
class_name StudioSplashScreen
## Tela de abertura do estúdio ("Um jogo LeuName Softwares"), exibida uma vez antes
## do menu principal. Toque na tela pula direto para o menu.

const DISPLAY_TIME := 2.2
const HERO_IMAGE := preload("res://assets/icons/icon_512.png")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	var hero := TextureRect.new()
	hero.texture = HERO_IMAGE
	hero.set_anchors_preset(Control.PRESET_FULL_RECT)
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hero)

	# escurece a parte de baixo para o texto ficar legível sobre a arte
	var scrim := Gradient.new()
	scrim.set_color(0, Color(0, 0, 0, 0))
	scrim.set_color(1, Color(0, 0, 0, 0.75))
	var scrim_tex := GradientTexture2D.new()
	scrim_tex.gradient = scrim
	scrim_tex.fill_from = Vector2(0, 0.55)
	scrim_tex.fill_to = Vector2(0, 1)
	var scrim_rect := TextureRect.new()
	scrim_rect.texture = scrim_tex
	scrim_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim_rect)

	var bottom_margin := MarginContainer.new()
	bottom_margin.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_margin.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bottom_margin.add_theme_constant_override("margin_bottom", 60)
	bottom_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_margin)

	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 4)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_margin.add_child(root)

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
