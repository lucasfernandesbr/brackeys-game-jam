class_name DocumentWindow
extends PanelContainer

@onready var title_label: Label = $VBox/TitleLabel
@onready var body_label: Label = $VBox/BodyLabel
@onready var close_btn: Button = $VBox/CloseButton


func _ready() -> void:
	close_btn.pressed.connect(hide)
	hide()


func show_document(doc_title: String, doc_body: String) -> void:
	title_label.text = doc_title
	body_label.text = doc_body
	show()
	move_to_front()
