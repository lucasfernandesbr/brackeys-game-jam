extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func _ready() -> void:
	EventBus.ui_click_sfx.connect(_play_click)
	_start_music()

func _start_music() -> void:
	set_bus_volume("Music", SettingsManager.music_volume)
	music_player.play()

func set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(linear, 0.001, 1.0)))

func _play_click() -> void:
	if sfx_player.stream != null:
		sfx_player.play()
