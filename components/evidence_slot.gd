@tool
class_name EvidenceSlot
extends Control

signal clicked(evidence)

const CLICK_MOVE_THRESHOLD := 6.0

@export_enum("photo", "document") var category: String = "photo"
@export var slot_tex: Texture2D = null:
	set(value):
		slot_tex = value
		_apply_slot_tex()
@export var pin_tex: Texture2D = null:
	set(value):
		pin_tex = value
		if pin_node != null:
			pin_node.texture = value
			if Engine.is_editor_hint():
				pin_node.visible = (value != null)

@onready var slot_texture: TextureRect = $SlotTexture
@onready var pin_node: TextureRect = $Pin

const RECORD_SHEET_SCENE := preload("res://components/record_sheet.tscn")
const RECORD_SHEET_SIZE := Vector2(384, 512)

var _occupied: bool = false
var _base_scale: Vector2 = Vector2.ONE
var _placed_ev: EvidenceData = null
var _content: Control = null
var _drag_tex: Texture2D = null
var _press_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	_base_scale = scale
	_apply_slot_tex()
	pin_node.texture = pin_tex
	if Engine.is_editor_hint():
		pin_node.visible = (pin_tex != null)
	else:
		pin_node.visible = false

func _apply_slot_tex() -> void:
	if slot_texture == null:
		return
	slot_texture.texture = slot_tex

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton) or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var mb := event as InputEventMouseButton
	if mb.pressed:
		_press_pos = mb.global_position
	elif _occupied and _placed_ev != null and not get_viewport().gui_is_dragging() \
			and mb.global_position.distance_to(_press_pos) <= CLICK_MOVE_THRESHOLD:
		clicked.emit(_placed_ev)

func _can_drop_data(_at_pos: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("evidence") is EvidenceData \
		and (data.evidence as EvidenceData).category == category and not _occupied

func _place_visual(ev: EvidenceData, tex: Texture2D) -> void:
	_drag_tex = tex
	if ev.category == "document" and ev.record != null:
		_content = _build_record_content(ev)
	else:
		_content = _build_photo_content(ev, tex)
	_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_content)
	if _content is RecordSheet:
		(_content as RecordSheet).setup(ev.record)

	pin_node.visible = true
	move_child(pin_node, -1)

	_occupied = true
	_placed_ev = ev
	reset_magnet()

func _build_photo_content(ev: EvidenceData, tex: Texture2D) -> Control:
	var rect := TextureRect.new()
	rect.texture = ev.photo if ev.photo != null else tex
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	return rect

func _build_record_content(ev: EvidenceData) -> Control:
	var sheet := RECORD_SHEET_SCENE.instantiate() as RecordSheet
	sheet.size = RECORD_SHEET_SIZE
	sheet.position = Vector2.ZERO
	sheet.scale = Vector2.ONE * (size.x / RECORD_SHEET_SIZE.x)
	return sheet

func restore(ev: EvidenceData, tex: Texture2D) -> void:
	_place_visual(ev, tex)

func _drop_data(_at_pos: Vector2, data: Variant) -> void:
	var ev: EvidenceData = data.evidence as EvidenceData
	_place_visual(ev, data.texture)
	GameState.place_evidence(ev.id, name)

	var source: EvidenceSlot = data.source_slot
	if source != null and source != self:
		source.clear()

func _get_drag_data(_at_pos: Vector2) -> Variant:
	if not _occupied or _placed_ev == null:
		return null
	set_drag_preview(_make_preview())
	if _content != null:
		_content.visible = false
	pin_node.visible = false
	return { "evidence": _placed_ev, "texture": _drag_tex, "source_slot": self }

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if _content != null:
			_content.visible = true
			pin_node.visible = true

func _make_preview() -> Control:
	var root := Control.new()
	root.custom_minimum_size = size
	root.size = size
	var tex := TextureRect.new()
	tex.texture = _drag_tex
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(tex)
	return root

func clear() -> void:
	if _content != null:
		_content.queue_free()
		_content = null
	_drag_tex = null
	pin_node.visible = false
	_occupied = false
	_placed_ev = null
	GameState.slot_assignments.erase(name)
	GameState.save_game()
	reset_magnet()

func update_magnet(data: Variant, mouse_global: Vector2) -> void:
	if not (data is Dictionary) or not (data.get("evidence") is EvidenceData):
		reset_magnet()
		return
	var ev: EvidenceData = data.evidence as EvidenceData
	if ev.category != category or _occupied:
		reset_magnet()
		return
	var center := global_position + size * 0.5 * scale
	var dist := center.distance_to(mouse_global)
	const THRESHOLD := 160.0
	if dist < THRESHOLD:
		var t := 1.0 - dist / THRESHOLD
		scale = _base_scale * (1.0 + 0.1 * t)
		modulate = Color(1.0 + 0.3 * t, 1.0 + 0.3 * t, 1.0, 1.0)
	else:
		reset_magnet()

func reset_magnet() -> void:
	scale = _base_scale
	modulate = Color.WHITE
