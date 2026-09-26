extends Node

func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.name = "UILayer"
	add_child(layer)
	var container := Control.new()
	container.name = "ScreenContainer"
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(container)
	SceneRouter.set_container(container)
	SceneRouter.go_to("studio_splash")
