@tool
class_name DraggableEvidence
extends Control

signal clicked(evidence)

const CLICK_MOVE_THRESHOLD := 6.0

@export var evidence: EvidenceData = null
@export var miniature_tex: Texture2D = null:
	set(value):
		miniature_tex = value
		if texture_rect:
			texture_rect.texture = value

@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var name_label: Label = $VBoxContainer/NameLabel

var _press_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if evidence != null and miniature_tex == null:
		miniature_tex = evidence.miniature
	texture_rect.texture = miniature_tex
	name_label.text = evidence.title if evidence != null else ""
	name_label.resized.connect(_fit_card_height)
	call_deferred("_fit_card_height")

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var mb := event as InputEventMouseButton
	if mb.pressed:
		_press_pos = mb.global_position
	elif not get_viewport().gui_is_dragging() \
			and mb.global_position.distance_to(_press_pos) <= CLICK_MOVE_THRESHOLD:
		clicked.emit(evidence)

func _get_drag_data(_at_pos: Vector2) -> Variant:
	if evidence == null:
		return null
	set_drag_preview(_make_preview())
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	return { "evidence": evidence, "texture": miniature_tex, "source_slot": null }

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_STOP
		visible = true

func _fit_card_height() -> void:
	const IMAGE_H := 64.0
	const SEPARATION := 2.0
	var label_h := name_label.get_line_count() * name_label.get_line_height()
	custom_minimum_size.y = IMAGE_H + SEPARATION + label_h

func _make_preview() -> Control:
	var root := Control.new()
	root.custom_minimum_size = size
	root.size = size
	var tex := TextureRect.new()
	tex.texture = miniature_tex
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(tex)
	return root
