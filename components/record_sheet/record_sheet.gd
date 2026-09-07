@tool
class_name RecordSheet
extends Control

@export var preview_data: RecordData = null:
	set(value):
		preview_data = value

		if title_label:
			setup(value)

@onready var vbox: VBoxContainer = $MarginContainer/VBoxContainer
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var header: HBoxContainer = $MarginContainer/VBoxContainer/Header
@onready var photo: TextureRect = $MarginContainer/VBoxContainer/Header/Photo
@onready var fields_container: VBoxContainer = $MarginContainer/VBoxContainer/Header/FieldsContainer
@onready var report_body: Label = $MarginContainer/VBoxContainer/ReportBody
@onready var footer: Control = $MarginContainer/VBoxContainer/Footer
@onready var stamp: TextureRect = $MarginContainer/VBoxContainer/Footer/Stamp
@onready var signature: TextureRect = $MarginContainer/VBoxContainer/Footer/Signature

const FIELD_FONT := preload("res://assets/fonts/TinyUnicode.ttf")
const FIELD_FONT_SIZE := 16
const SEPARATOR_COLOR := Color(0.06666667, 0.06666667, 0.06666667, 1)
const SEPARATOR_SPACING := 40


func _ready() -> void:
	if Engine.is_editor_hint() and preview_data != null:
		setup(preview_data)


func setup(data: RecordData) -> void:
	if data == null:
		return
	title_label.text = data.title
	photo.texture = data.photo
	photo.visible = data.photo != null
	_rebuild_fields(data.fields)
	header.visible = data.photo != null or not data.fields.is_empty()
	report_body.text = data.report_body
	report_body.visible = data.report_body != ""
	stamp.texture = data.stamp
	stamp.visible = data.stamp != null
	signature.texture = data.signature
	signature.visible = data.signature != null
	footer.visible = stamp.visible or signature.visible
	_update_separators()


func _rebuild_fields(fields: Array) -> void:
	for c in fields_container.get_children():
		c.queue_free()

	for f in fields:
		var field := f as RecordField

		if field == null:
			continue
		var lbl := Label.new()

		lbl.text = "%s %s" % [field.label, field.value] if field.label != "" else field.value
		lbl.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		lbl.add_theme_font_override("font", FIELD_FONT)
		lbl.add_theme_font_size_override("font_size", FIELD_FONT_SIZE)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fields_container.add_child(lbl)


func _update_separators() -> void:
	for c in vbox.get_children():
		if c.is_in_group("record_separator"):
			vbox.remove_child(c)
			c.free()

	var sections := [title_label, header, report_body, footer]
	var visible_sections := []

	for s in sections:
		if s.visible:
			visible_sections.append(s)

	for i in range(1, visible_sections.size()):
		var sep := _make_separator()

		vbox.add_child(sep)
		vbox.move_child(sep, visible_sections[i].get_index())


func _make_separator() -> HSeparator:
	var sep := HSeparator.new()
	var style := StyleBoxLine.new()

	style.color = SEPARATOR_COLOR
	sep.add_theme_stylebox_override("separator", style)
	sep.add_theme_constant_override("separation", SEPARATOR_SPACING)
	sep.add_to_group("record_separator")
	return sep
