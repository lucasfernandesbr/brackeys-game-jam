@tool
class_name Hotspot
extends TextureButton

@export var target_scene_key: String = ""
@export var normal_texture: Texture2D:
	set(value):
		normal_texture = value
		texture_normal = value
@export var hover_overlay_path: NodePath

var _hover_overlay: CanvasItem

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not hover_overlay_path.is_empty():
		_hover_overlay = get_node_or_null(hover_overlay_path) as CanvasItem
	if is_instance_valid(_hover_overlay):
		_hover_overlay.visible = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

func _on_mouse_entered() -> void:
	if is_instance_valid(_hover_overlay):
		_hover_overlay.visible = true

func _on_mouse_exited() -> void:
	if is_instance_valid(_hover_overlay):
		_hover_overlay.visible = false

func _on_pressed() -> void:
	if target_scene_key.is_empty():
		return
	EventBus.navigate_requested.emit(target_scene_key)
