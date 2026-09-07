extends Control

@onready var continue_btn: Button = $VBox/ContinueButton
@onready var start_btn: Button = $VBox/StartButton
@onready var settings_btn: Button = $VBox/SettingsButton
@onready var credits_btn: Button = $VBox/CreditsButton
@onready var quit_btn: Button = $VBox/QuitButton


func _ready() -> void:
	continue_btn.visible = GameState.has_save()
	continue_btn.pressed.connect(_on_continue)
	start_btn.pressed.connect(_on_new_game)
	settings_btn.pressed.connect(_on_settings)
	credits_btn.pressed.connect(_on_credits)
	quit_btn.pressed.connect(_on_quit)


func _on_continue() -> void:
	GameState.load_game()
	EventBus.navigate_requested.emit("main")


func _on_new_game() -> void:
	GameState.new_game(load(GameState.DEFAULT_CASE_PATH))
	EventBus.navigate_requested.emit("intro")


func _on_settings() -> void:
	EventBus.navigate_requested.emit("settings")


func _on_credits() -> void:
	EventBus.navigate_requested.emit("credits")


func _on_quit() -> void:
	get_tree().quit()
