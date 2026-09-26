extends Node
## Troca as telas (Control) dentro do container definido por Main. Cada tela é uma classe
## GDScript própria (extends Control) com um método opcional setup(params) chamado após
## a instância entrar na árvore.

var _container: Control
var _current_screen: Control

var _screens: Dictionary = {}

func _ready() -> void:
	_screens = {
		"studio_splash": preload("res://scripts/ui/studio_splash_screen.gd"),
		"main_menu": preload("res://scripts/ui/main_menu_screen.gd"),
		"world_select": preload("res://scripts/ui/world_select_screen.gd"),
		"level_map": preload("res://scripts/ui/level_map_screen.gd"),
		"game": preload("res://scripts/ui/game_screen.gd"),
		"coming_soon": preload("res://scripts/ui/coming_soon_screen.gd"),
	}

func set_container(container: Control) -> void:
	_container = container

func go_to(screen_name: String, params: Dictionary = {}) -> void:
	if not _screens.has(screen_name):
		push_error("SceneRouter: tela desconhecida '%s'" % screen_name)
		return
	if _current_screen and is_instance_valid(_current_screen):
		_current_screen.queue_free()
		_current_screen = null
	var script: GDScript = _screens[screen_name]
	var screen: Control = script.new()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	_container.add_child(screen)
	_current_screen = screen
	if screen.has_method("setup"):
		screen.setup(params)
