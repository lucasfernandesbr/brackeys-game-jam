extends Control

const PHOTO_SHEET := preload("res://assets/sprites/board/photo_miniature.png")
const DOC_SHEET := preload("res://assets/sprites/record_miniature.png")
const PHOTO_REGION := Rect2(97, 37, 40, 40)

@onready var board_documents: Control = $BoardDocuments
@onready var hotspot_phone: Hotspot = $HotspotPhone
@onready var hotspot_desktop: Hotspot = $HotspotDesktop
@onready var hotspot_board: Hotspot = $HotspotBoard
@onready var email_notification: Control = $EmailNotification
@onready var phone_ring_player: AudioStreamPlayer = $PhoneRingPlayer
@onready var back_menu_button: TextureButton = $BackMenuButton


func _ready() -> void:
	if GameState.current_case == null:
		GameState.start_case(load(GameState.DEFAULT_CASE_PATH))

	_show_placed_evidences()
	hotspot_phone.pressed.connect(_on_phone_pressed)
	back_menu_button.pressed.connect(_on_back_menu_pressed)

	if not GameState.phone_answered:
		_begin_phone_ring_intro()
	else:
		_set_phase_answered()


func _show_placed_evidences() -> void:
	for child in board_documents.get_children():
		_show_evidence(child.name, child as TextureRect)


func _show_evidence(slot_id: String, target: TextureRect) -> void:
	var id: String = GameState.slot_assignments.get(slot_id, "")

	if id == "" or GameState.current_case == null:
		target.visible = false
		return

	var ev: EvidenceData = null

	for e in GameState.current_case.evidences:
		if e.id == id:
			ev = e
			break

	if ev == null:
		target.visible = false
		return

	target.texture = ev.miniature if ev.miniature != null else _placeholder_for(ev.category)
	target.visible = true


func _placeholder_for(category: String) -> Texture2D:
	if category == "photo":
		var at := AtlasTexture.new()

		at.atlas = PHOTO_SHEET
		at.region = PHOTO_REGION
		at.filter_clip = true
		return at

	return DOC_SHEET


func _set_hotspot_enabled(h: Hotspot, enabled: bool) -> void:
	h.disabled = not enabled
	h.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE

	if not enabled:
		var overlay := h.get_node_or_null(h.hover_overlay_path) as CanvasItem

		if is_instance_valid(overlay):
			overlay.visible = false


func _begin_phone_ring_intro() -> void:
	_start_phone_ring()
	_set_hotspot_enabled(hotspot_phone, true)
	_set_hotspot_enabled(hotspot_desktop, false)
	_set_hotspot_enabled(hotspot_board, false)
	email_notification.visible = false


func _start_phone_ring() -> void:
	phone_ring_player.stream.loop = true
	phone_ring_player.play()


func _on_phone_pressed() -> void:
	phone_ring_player.stop()
	EventBus.navigate_requested.emit("case_presentation")


func _on_back_menu_pressed() -> void:
	phone_ring_player.stop()
	EventBus.navigate_requested.emit("main_menu")


func _set_phase_answered() -> void:
	_set_hotspot_enabled(hotspot_phone, false)
	_set_hotspot_enabled(hotspot_desktop, true)
	_set_hotspot_enabled(hotspot_board, true)
	_update_email_notification()


func _update_email_notification() -> void:
	email_notification.visible = GameState.phone_answered and not GameState.email_read
