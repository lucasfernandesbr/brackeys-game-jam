extends Control

@onready var title_card: Control = $TitleCard

const TITLE_FADE_IN := 1.0
const TITLE_HOLD := 2.0
const TITLE_FADE_OUT := 1.0


func _ready() -> void:
	_play_title_card()


func _play_title_card() -> void:
	title_card.visible = true
	title_card.modulate.a = 0.0

	var tween := create_tween()

	tween.tween_property(title_card, "modulate:a", 1.0, TITLE_FADE_IN)
	tween.tween_interval(TITLE_HOLD)
	tween.tween_property(title_card, "modulate:a", 0.0, TITLE_FADE_OUT)
	tween.tween_callback(_on_title_card_finished)


func _on_title_card_finished() -> void:
	title_card.visible = false
	EventBus.navigate_requested.emit("main")
