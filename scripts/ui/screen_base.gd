extends Control
class_name ScreenBase
## Base comum para as telas do jogo: paleta de cores e helpers para montar UI por
## código (Label, Button, painel, barra de moedas/gemas/estrelas, barra superior),
## evitando duplicar o mesmo boilerplate em cada tela.

const COLOR_BG_TOP := Color(0.09, 0.11, 0.2)
const COLOR_BG_BOTTOM := Color(0.05, 0.06, 0.13)
const COLOR_PRIMARY := Color(0.18, 0.56, 0.94)
const COLOR_ACCENT := Color(0.98, 0.75, 0.18)
const COLOR_SUCCESS := Color(0.3, 0.72, 0.35)
const COLOR_DANGER := Color(0.85, 0.25, 0.25)
const COLOR_TEXT := Color(0.95, 0.96, 1.0)
const COLOR_TEXT_DIM := Color(0.7, 0.73, 0.85)

func add_background_gradient(top: Color = COLOR_BG_TOP, bottom: Color = COLOR_BG_BOTTOM) -> void:
	var gradient := Gradient.new()
	gradient.set_color(0, top)
	gradient.set_color(1, bottom)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	texture.width = 4
	texture.height = 512
	var rect := TextureRect.new()
	rect.texture = texture
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
	move_child(rect, 0)

func make_label(text: String, size: int = 28, color: Color = COLOR_TEXT) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func make_button(text: String, color: Color = COLOR_PRIMARY, min_size: Vector2 = Vector2(280, 74)) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_stylebox_override("normal", _button_style(color))
	button.add_theme_stylebox_override("hover", _button_style(color.lightened(0.12)))
	button.add_theme_stylebox_override("pressed", _button_style(color.darkened(0.12)))
	button.add_theme_stylebox_override("disabled", _button_style(color.darkened(0.45)))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_disabled_color", COLOR_TEXT_DIM)
	return button

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(18)
	return style

func make_panel(color: Color = Color(1, 1, 1, 0.06)) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(20)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	return panel

func build_currency_bar() -> HBoxContainer:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	bar.add_child(_currency_chip("🪙", str(SaveManager.data.get("coins_total", 0)), COLOR_ACCENT))
	bar.add_child(_currency_chip("💎", str(SaveManager.data.get("gems_total", 0)), Color(0.4, 0.85, 0.95)))
	bar.add_child(_currency_chip("⭐", str(SaveManager.total_stars_all_worlds()), Color(1.0, 0.9, 0.3)))
	return bar

func _currency_chip(icon: String, value: String, color: Color) -> PanelContainer:
	var panel := make_panel(Color(1, 1, 1, 0.08))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(make_label(icon, 20, color))
	row.add_child(make_label(value, 20, COLOR_TEXT))
	panel.add_child(row)
	return panel

func build_top_bar(on_back: Callable = Callable()) -> HBoxContainer:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	if on_back.is_valid():
		var back := make_button("← Voltar", Color(1, 1, 1, 0.1), Vector2(150, 56))
		back.pressed.connect(on_back)
		bar.add_child(back)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(spacer)
	bar.add_child(build_currency_bar())
	var settings := make_button("⚙", Color(1, 1, 1, 0.1), Vector2(56, 56))
	settings.pressed.connect(func(): SceneRouter.go_to("coming_soon", {"title": "Configurações"}))
	bar.add_child(settings)
	return bar

func spacer(height: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, height)
	return c
