extends Node

const CONFIG_PATH := "user://settings.cfg"
const RESOLUTIONS = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
]

var master_volume: float = 1.0
var music_volume: float = 1.0
var resolution: Vector2i = Vector2i(1280, 720)

func _ready() -> void:
	load_settings()
	apply()

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return
	master_volume = cfg.get_value("audio", "master_volume", 1.0)
	music_volume = cfg.get_value("audio", "music_volume", 1.0)
	var idx: int = cfg.get_value("display", "resolution_index", 0)
	resolution = RESOLUTIONS[clampi(idx, 0, RESOLUTIONS.size() - 1)]

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("display", "resolution_index", get_resolution_index())
	cfg.save(CONFIG_PATH)

func apply() -> void:
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(master_volume))
	if AudioServer.get_bus_index("Music") >= 0:
		AudioManager.set_bus_volume("Music", music_volume)
	_apply_resolution()
	EventBus.settings_changed.emit()

func _apply_resolution() -> void:
	if DisplayServer.get_name() == "embedded":
		return
	var win := get_window()
	if win.mode == Window.MODE_FULLSCREEN or win.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		return
	DisplayServer.window_set_size(resolution)
	var screen := DisplayServer.window_get_current_screen()
	var pos := DisplayServer.screen_get_position(screen) \
		+ (DisplayServer.screen_get_size(screen) - resolution) / 2
	DisplayServer.window_set_position(pos)

func get_resolution_index() -> int:
	for i in RESOLUTIONS.size():
		if RESOLUTIONS[i] == resolution:
			return i
	return 0

func set_master_volume(linear: float) -> void:
	master_volume = clampf(linear, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(master_volume))

func set_music_volume(linear: float) -> void:
	music_volume = clampf(linear, 0.0, 1.0)
	if AudioServer.get_bus_index("Music") >= 0:
		AudioManager.set_bus_volume("Music", music_volume)

func set_resolution(index: int) -> void:
	resolution = RESOLUTIONS[clampi(index, 0, RESOLUTIONS.size() - 1)]