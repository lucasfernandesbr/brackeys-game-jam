extends CanvasLayer

const SCENES: Dictionary = {
	"main_menu": "res://scenes/main_menu.tscn",
	"settings": "res://scenes/settings.tscn",
	"credits": "res://scenes/credits.tscn",
	"intro": "res://scenes/intro.tscn",
	"case_presentation": "res://scenes/case_presentation.tscn",
	"main": "res://scenes/main_scene.tscn",
	"desktop": "res://scenes/desktop.tscn",
	"board": "res://scenes/board.tscn",
}

@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	EventBus.navigate_requested.connect(_on_navigate)
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func goto(scene_key: String) -> void:
	var path: String = SCENES.get(scene_key, "")
	if path.is_empty():
		push_error("SceneManager: unknown key '%s'" % scene_key)
		return
	await _fade(1.0)
	get_tree().change_scene_to_file(path)
	await _fade(0.0)

func _fade(alpha: float) -> void:
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP if alpha > 0.0 else Control.MOUSE_FILTER_IGNORE
	var tween := get_tree().create_tween()
	tween.tween_property(fade_rect, "color:a", alpha, 0.3)
	await tween.finished

func _on_navigate(scene_key: String) -> void:
	goto(scene_key)
