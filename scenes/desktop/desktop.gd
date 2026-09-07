# gdlint:ignore-file:file-length - scene controller (arquivo grande e esperado)
extends Control

const FOLDER_ITEM_SCENE := preload("res://components/folder_item/folder_item.tscn")
const FILE_IMAGE_ICON := preload("res://assets/sprites/desktop/evidence/file_image_icon.png")
const FILE_DOC_ICON := preload("res://assets/sprites/desktop/evidence/file_evidence_icon.png")
const FILE_IMAGE_ICON_HOVER := preload(
	"res://assets/sprites/desktop/evidence/file_image_icon_hover.png"
)
const FILE_DOC_ICON_HOVER := preload(
	"res://assets/sprites/desktop/evidence/file_evidence_icon_hover.png"
)
const DOC_FONT := preload("res://assets/fonts/TinyUnicode.ttf")
const DOC_COLOR := Color(0.06666667, 0.06666667, 0.06666667)
const DOC_FONT_SIZE := 24

const EMAIL_PIVOT := Vector2(560.0, 280.0)
const FOLDER_PIVOT := Vector2(350.0, 248.0)
const EVIDENCE_PIVOT := Vector2(562.0, 280.0)
const ALERT_PIVOT := Vector2(658.0, 319.0)

const OVERLAY_ALPHA := 0.6
const FADE_IN := 0.2
const FADE_OUT := 0.12
const WINDOW_START_SCALE := Vector2(0.85, 0.85)
const WINDOW_FULL_SCALE := Vector2(1.0, 1.0)

@onready var evidence_folder_icon: TextureButton = $Icons/EvidencesFolder/EvidenceFolderIcon
@onready var email_read_icon: TextureButton = $Icons/EmailIcon/EmailIcon
@onready var email_new_icon: TextureButton = $Icons/EmailIcon/EmailNewIcon
@onready var trash_icon: TextureButton = $Icons/TrashBin/TrashBinIcon
@onready var email: Control = $Email
@onready var folder_window: Control = $FolderWindow
@onready var evidence_window: Control = $EvidenceWindow
@onready var close_button_email: Button = $Email/CloseEmailButton
@onready var close_folder_button: Button = $FolderWindow/CloseFolderButton
@onready var items_container: GridContainer = $FolderWindow/ItemsContainer
@onready var close_evidence_button: Button = $EvidenceWindow/CloseEvidenceButton
@onready var print_button: Button = $EvidenceWindow/PrintButton
@onready var evidence_photo: TextureRect = $EvidenceWindow/Photo
@onready var doc_content: VBoxContainer = $EvidenceWindow/DocContent
@onready var doc_title: Label = $EvidenceWindow/DocContent/TitleLabel
@onready var doc_header: HBoxContainer = $EvidenceWindow/DocContent/Header
@onready var doc_photo: TextureRect = $EvidenceWindow/DocContent/Header/DocPhoto
@onready var doc_fields: VBoxContainer = $EvidenceWindow/DocContent/Header/FieldsContainer
@onready var doc_body: RichTextLabel = $EvidenceWindow/DocContent/BodyLabel
@onready var doc_footer: HBoxContainer = $EvidenceWindow/DocContent/Footer
@onready var doc_stamp: TextureRect = $EvidenceWindow/DocContent/Footer/Stamp
@onready var doc_signature: TextureRect = $EvidenceWindow/DocContent/Footer/Signature
@onready var workspace_close_button: Button = $WorkspaceCloseButton
@onready var modal_overlay: ColorRect = $ModalOverlay
@onready var modal_overlay_evidence_window: ColorRect = $EvidenceWindowModalOverlay
@onready var print_alert: Control = $PrintAlert
@onready var printing_alert_overlay: ColorRect = $PrintingAlertWindowModalOverlay
@onready var close_printing_alert_button: Button = $PrintAlert/ClosePrintingAlertButton

var _current_folder := ""
var _current_evidence: EvidenceData = null


func _ready() -> void:
	email_read_icon.pressed.connect(_on_email_pressed)
	email_new_icon.pressed.connect(_on_email_pressed)
	_update_email_icons()
	workspace_close_button.pressed.connect(_on_close_desktop_pressed)
	close_button_email.pressed.connect(_on_close_email_pressed)
	evidence_folder_icon.pressed.connect(_on_evidence_folder_pressed)
	trash_icon.pressed.connect(_on_trash_pressed)
	close_folder_button.pressed.connect(_on_close_folder_pressed)
	close_evidence_button.pressed.connect(_on_close_evidence_pressed)
	print_button.pressed.connect(_on_print_pressed)
	close_printing_alert_button.pressed.connect(_on_close_print_alert_pressed)
	modal_overlay.visible = false
	modal_overlay_evidence_window.visible = false
	printing_alert_overlay.visible = false
	email.visible = false
	email.pivot_offset = EMAIL_PIVOT
	folder_window.visible = false
	folder_window.pivot_offset = FOLDER_PIVOT
	evidence_window.visible = false
	evidence_window.pivot_offset = EVIDENCE_PIVOT
	print_alert.visible = false
	print_alert.pivot_offset = ALERT_PIVOT


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		EventBus.ui_click_sfx.emit()


func _update_email_icons() -> void:
	email_read_icon.visible = GameState.email_read
	email_new_icon.visible = not GameState.email_read


func _on_email_pressed() -> void:
	if not GameState.email_read:
		GameState.email_read = true
		GameState.save_game()
		_update_email_icons()

	_open_window(email, true)


func _on_close_email_pressed() -> void:
	_close_window(email, true)


func _on_close_desktop_pressed() -> void:
	EventBus.navigate_requested.emit("main")


func _on_evidence_folder_pressed() -> void:
	_current_folder = "evidence"
	_populate_folder_items()
	_open_window(folder_window, true)


func _populate_folder_items() -> void:
	for c in items_container.get_children():
		c.queue_free()

	if _current_folder != "evidence" or not GameState.email_read:
		return
	var case_data: CaseData = GameState.current_case

	if case_data == null:
		return
	for ev in case_data.evidences:
		var item := FOLDER_ITEM_SCENE.instantiate()
		var icon_btn := item.get_node("Icon") as TextureButton
		var is_photo := ev.category == "photo"

		icon_btn.texture_normal = FILE_IMAGE_ICON if is_photo else FILE_DOC_ICON
		icon_btn.texture_hover = FILE_IMAGE_ICON_HOVER if is_photo else FILE_DOC_ICON_HOVER
		(item.get_node("Name") as Label).text = ev.title
		icon_btn.pressed.connect(_on_evidence_item_pressed.bind(ev))
		items_container.add_child(item)


func _on_trash_pressed() -> void:
	_current_folder = "trash"
	_populate_folder_items()
	_open_window(folder_window, true)


func _on_close_folder_pressed() -> void:
	_close_window(folder_window, true)


func _on_evidence_item_pressed(ev: EvidenceData) -> void:
	_current_evidence = ev
	_show_evidence_content(ev)
	_update_print_button(ev)
	_open_window(evidence_window, false)

	modal_overlay_evidence_window.color.a = 0.0
	modal_overlay_evidence_window.visible = true

	var tween := get_tree().create_tween()

	tween.set_parallel(true)
	tween.tween_property(modal_overlay_evidence_window, "color:a", OVERLAY_ALPHA, FADE_IN)


func _show_evidence_content(ev: EvidenceData) -> void:
	if ev.category == "photo":
		evidence_photo.texture = ev.photo
		evidence_photo.visible = true
		doc_content.visible = false
	else:
		_populate_doc_content(ev.record)
		doc_content.visible = true
		evidence_photo.visible = false


func _populate_doc_content(record: RecordData) -> void:
	for c in doc_fields.get_children():
		c.queue_free()

	if record == null:
		doc_title.text = ""
		doc_body.text = ""
		doc_header.visible = false
		doc_footer.visible = false
		return

	doc_title.text = record.title
	doc_photo.texture = record.photo
	doc_photo.visible = record.photo != null

	for f in record.fields:
		var field := f as RecordField

		if field != null:
			doc_fields.add_child(_make_field_label(field))

	doc_header.visible = record.photo != null or not record.fields.is_empty()
	doc_body.text = record.report_body
	doc_body.visible = record.report_body != ""
	doc_stamp.texture = record.stamp
	doc_stamp.visible = record.stamp != null
	doc_signature.texture = record.signature
	doc_signature.visible = record.signature != null
	doc_footer.visible = doc_stamp.visible or doc_signature.visible


func _make_field_label(field: RecordField) -> Label:
	var lbl := Label.new()

	lbl.text = "%s %s" % [field.label, field.value] if field.label != "" else field.value
	lbl.add_theme_font_override("font", DOC_FONT)
	lbl.add_theme_font_size_override("font_size", DOC_FONT_SIZE)
	lbl.add_theme_color_override("font_color", DOC_COLOR)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl


func _update_print_button(ev: EvidenceData) -> void:
	var printed := GameState.is_printed(ev.id)

	print_button.disabled = printed
	print_button.text = "Printed" if printed else "Print"


func _on_print_pressed() -> void:
	if _current_evidence == null:
		return

	GameState.mark_printed(_current_evidence.id)
	_update_print_button(_current_evidence)
	_open_window(print_alert, false)

	printing_alert_overlay.color.a = 0.0
	printing_alert_overlay.visible = true

	var tween := get_tree().create_tween()

	tween.set_parallel(true)
	tween.tween_property(printing_alert_overlay, "color:a", OVERLAY_ALPHA, FADE_IN)


func _on_close_print_alert_pressed() -> void:
	_close_window(print_alert, false)

	var tween := get_tree().create_tween()

	tween.set_parallel(true)
	tween.tween_property(printing_alert_overlay, "color:a", 0.0, FADE_OUT)
	printing_alert_overlay.visible = false


func _on_close_evidence_pressed() -> void:
	_close_window(evidence_window, false)

	var tween := get_tree().create_tween()

	tween.set_parallel(true)
	tween.tween_property(modal_overlay_evidence_window, "color:a", 0.0, FADE_OUT)
	modal_overlay_evidence_window.visible = false


func _open_window(win: Control, use_overlay: bool) -> void:
	if use_overlay:
		modal_overlay.color.a = 0.0
		modal_overlay.visible = true

	win.scale = WINDOW_START_SCALE
	win.modulate.a = 0.0
	win.visible = true

	var tween := get_tree().create_tween()

	tween.set_parallel(true)

	if use_overlay:
		tween.tween_property(modal_overlay, "color:a", OVERLAY_ALPHA, FADE_IN)

	(
		tween
		. tween_property(win, "scale", WINDOW_FULL_SCALE, FADE_IN)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	tween.tween_property(win, "modulate:a", 1.0, FADE_IN)


func _close_window(win: Control, use_overlay: bool) -> void:
	var tween := get_tree().create_tween()

	tween.set_parallel(true)

	if use_overlay:
		tween.tween_property(modal_overlay, "color:a", 0.0, FADE_OUT)

	tween.tween_property(win, "scale", WINDOW_START_SCALE, FADE_OUT)
	tween.tween_property(win, "modulate:a", 0.0, FADE_OUT)
	await tween.finished
	win.visible = false

	if use_overlay:
		modal_overlay.visible = false
