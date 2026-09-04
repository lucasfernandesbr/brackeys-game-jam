@tool
extends Control

const EVIDENCE_SCENE := "res://components/draggable_evidence.tscn"
const PLACEHOLDER_PHOTO_SHEET := preload("res://assets/sprites/board/photo_miniature.png")
const PLACEHOLDER_DOC_SHEET := preload("res://assets/sprites/record_miniature.png")

const PHOTO_REGION := Rect2(97, 37, 40, 40)

const LIST_CARD_HEIGHT := 64.0
const LIST_LABEL_HEIGHT := 18.0

@onready var feedback_label: Control = $BoardArea/WrongAnswer
@onready var close_case_btn: Button = $SidePanel/CloseButton
@onready var back_btn: Button = $SidePanel/BackButton
@onready var evidence_grid: GridContainer = $SidePanel/EvidenceScroll/EvidenceCenter/EvidenceGrid
@onready var photo_viewer: Control = $PhotoViewer
@onready var viewer_overlay: ColorRect = $PhotoViewer/Overlay
@onready var viewer_photo: TextureRect = $PhotoViewer/Photo
@onready var viewer_close: TextureButton = $PhotoViewer/CloseButton
@onready var viewer_record: RecordSheet = $PhotoViewer/RecordSheet
@onready var win_screen: Control = $WinScreen
@onready var back_to_menu: Button = $WinScreen/Button

var _slots: Array = []

func _ready() -> void:
	if Engine.is_editor_hint():
		_populate_list()
		return
	_slots = [
		$BoardArea/SlotContainer/Photo1/PhotoSlot1,
		$BoardArea/SlotContainer/Photo2/PhotoSlot2,
		$BoardArea/SlotContainer/Photo3/PhotoSlot3,
		$BoardArea/SlotContainer/Document1/DocumentSlot1,
	]
	for slot in _slots:
		(slot as EvidenceSlot).clicked.connect(_on_evidence_clicked)
	feedback_label.visible = false
	photo_viewer.visible = false
	close_case_btn.pressed.connect(_on_close_case)
	back_btn.pressed.connect(_on_back)
	viewer_close.pressed.connect(_close_photo_viewer)
	viewer_overlay.gui_input.connect(_on_viewer_overlay_input)
	back_to_menu.pressed.connect(_on_back_to_menu)
	EventBus.case_closed.connect(_on_case_closed)
	EventBus.evidence_placed.connect(_on_evidence_changed)
	EventBus.evidence_removed.connect(_on_evidence_changed)
	_restore_slots()
	_populate_list()

func _restore_slots() -> void:
	var case_data: CaseData = GameState.current_case
	if case_data == null:
		return
	for slot in _slots:
		var ev_slot := slot as EvidenceSlot
		var id: String = GameState.slot_assignments.get(ev_slot.name, "")
		if id == "":
			continue
		var ev: EvidenceData = null
		for e in case_data.evidences:
			if e.id == id:
				ev = e
				break
		if ev == null:
			continue
		var tex: Texture2D = ev.miniature
		if tex == null:
			tex = _placeholder_for(ev.category)
		ev_slot.restore(ev, tex)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var vp := get_viewport()
	if vp.gui_is_dragging():
		var data: Variant = vp.gui_get_drag_data()
		var mouse := get_global_mouse_position()
		for slot in _slots:
			(slot as EvidenceSlot).update_magnet(data, mouse)
	else:
		for slot in _slots:
			(slot as EvidenceSlot).reset_magnet()

func _populate_list() -> void:
	for c in evidence_grid.get_children():
		c.queue_free()
	var case_data: CaseData = null
	if Engine.is_editor_hint():
		case_data = load("res://data/cases/case_stub.tres")
	else:
		case_data = GameState.current_case
	if case_data == null:
		return
	var packed: PackedScene = load(EVIDENCE_SCENE)
	var photos: Array = case_data.evidences.filter(func(e): return e.category == "photo")
	var docs: Array = case_data.evidences.filter(func(e): return e.category != "photo")
	for ev in photos + docs:
		if not Engine.is_editor_hint() and not GameState.is_evidence_available(ev):
			continue
		if not Engine.is_editor_hint() and not GameState.is_printed(ev.id):
			continue
		if not Engine.is_editor_hint() and ev.id in GameState.placed_evidence_ids:
			continue
		var card := packed.instantiate() as DraggableEvidence
		card.evidence = ev
		var tex: Texture2D = ev.miniature
		if tex == null:
			tex = _placeholder_for(ev.category)
		card.miniature_tex = tex
		card.custom_minimum_size = _card_size_for(tex)
		if not Engine.is_editor_hint():
			card.clicked.connect(_on_evidence_clicked)
		evidence_grid.add_child(card)

func _placeholder_for(category: String) -> Texture2D:
	if category == "photo":
		var at := AtlasTexture.new()
		at.atlas = PLACEHOLDER_PHOTO_SHEET
		at.region = PHOTO_REGION
		at.filter_clip = true
		return at
	return PLACEHOLDER_DOC_SHEET

func _card_size_for(tex: Texture2D) -> Vector2:
	var size: Vector2
	if tex is AtlasTexture:
		size = (tex as AtlasTexture).region.size
	elif tex != null:
		size = tex.get_size()
	else:
		return Vector2(LIST_CARD_HEIGHT, LIST_CARD_HEIGHT + LIST_LABEL_HEIGHT)
	var h := LIST_CARD_HEIGHT
	return Vector2(size.x / size.y * h, h + LIST_LABEL_HEIGHT)

func _on_evidence_changed(_id: String) -> void:
	_populate_list()

func _on_evidence_clicked(ev: EvidenceData) -> void:
	if ev == null:
		return
	if ev.category == "photo":
		var tex: Texture2D = ev.photo
		if tex == null:
			tex = _placeholder_for("photo")
		_open_photo_viewer(tex)
	elif ev.record != null:
		_open_record_viewer(ev.record)

func _open_photo_viewer(tex: Texture2D) -> void:
	viewer_photo.texture = tex
	viewer_photo.size = tex.get_size() * 4.0
	viewer_photo.position = (photo_viewer.size - viewer_photo.size) * 0.5
	viewer_photo.visible = true
	viewer_record.visible = false
	_show_viewer()

func _open_record_viewer(record: RecordData) -> void:
	viewer_record.setup(record)
	viewer_record.visible = true
	viewer_photo.visible = false
	_show_viewer()

func _show_viewer() -> void:
	viewer_overlay.color.a = 0.0
	photo_viewer.modulate.a = 0.0
	photo_viewer.visible = true
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(viewer_overlay, "color:a", 0.55, 0.2)
	tween.tween_property(photo_viewer, "modulate:a", 1.0, 0.2)

func _close_photo_viewer() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(photo_viewer, "modulate:a", 0.0, 0.12)
	await tween.finished
	photo_viewer.visible = false

func _on_viewer_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_close_photo_viewer()

func _on_close_case() -> void:
	GameState.evaluate()

func _on_back() -> void:
	EventBus.navigate_requested.emit("main")

func _on_back_to_menu() -> void:
	EventBus.navigate_requested.emit("main_menu")

func _on_case_closed(is_correct: bool) -> void:
	if is_correct:
		_show_win_screen()
		return
	feedback_label.visible = true

func _show_win_screen() -> void:
	win_screen.modulate.a = 0.0
	win_screen.visible = true
	var tween := get_tree().create_tween()
	tween.tween_property(win_screen, "modulate:a", 1.0, 0.6)
