extends Control

const PARAGRAPHS: Array[String] = [
	# Narrative paragraphs are intentionally single long string literals.
	# gdlint:disable=max-line-length
	# gdlint:ignore-next-line:long-line
	"Hey buddy,\nDid anyone tell you about the case in Bright Mount yet? The rich old man who died in his wine cellar? It's been a week now. The deputy team couldn't crack it and something still seems off... I need you to dig into this. If something slipped through, you'll be the one to find it.",
	# gdlint:ignore-next-line:long-line
	"I've sent the evidence to your email. PRINT each one so you can use it on your INVESTIGATION BOARD. Connect the evidence based on your findings and the instructions on the board. When you think everything is set, just send over your report. I'll fill you in on the investigation tomorrow and send you new intel. Let me know what you find and good luck out there!"
	# gdlint:enable=max-line-length
]
const CHARS_PER_SECOND := 40.0

var _paragraph_index := 0
var _tween: Tween


func _ready() -> void:
	if GameState.phone_answered:
		EventBus.navigate_requested.emit("main")
		return

	%NextButton.pressed.connect(_on_next_pressed)
	_show_paragraph(0)


func _show_paragraph(index: int) -> void:
	var text: String = PARAGRAPHS[index]

	%TextLabel.text = text
	%TextLabel.visible_ratio = 0.0

	var duration: float = text.length() / CHARS_PER_SECOND

	_tween = create_tween()
	_tween.tween_property(%TextLabel, "visible_ratio", 1.0, duration)
	%NextButton.text = "Start" if index == PARAGRAPHS.size() - 1 else "Continue"


func _on_next_pressed() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
		%TextLabel.visible_ratio = 1.0
		return

	_paragraph_index += 1

	if _paragraph_index >= PARAGRAPHS.size():
		GameState.phone_answered = true
		GameState.save_game()
		EventBus.navigate_requested.emit("main")
	else:
		_show_paragraph(_paragraph_index)
