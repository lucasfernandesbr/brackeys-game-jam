extends Control

@onready var back_btn: Button = $BackButton


func _ready() -> void:
	back_btn.pressed.connect(_on_back)


func _on_back() -> void:
	EventBus.navigate_requested.emit("main_menu")
