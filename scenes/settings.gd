extends Control

@onready var resolution_option: OptionButton = $VBox/ResolutionRow/ResolutionOption
@onready var volume_slider: HSlider = $VBox/VolumeRow/VolumeSlider
@onready var music_slider: HSlider = $VBox/MusicRow/MusicSlider
@onready var save_btn: Button = $VBox/SaveButton
@onready var back_btn: Button = $VBox/BackButton

func _ready() -> void:
	for res in SettingsManager.RESOLUTIONS:
		resolution_option.add_item("%dx%d" % [res.x, res.y])
	resolution_option.select(SettingsManager.get_resolution_index())
	volume_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	save_btn.pressed.connect(_on_save)
	back_btn.pressed.connect(_on_back)

func _on_save() -> void:
	SettingsManager.set_master_volume(volume_slider.value)
	SettingsManager.set_music_volume(music_slider.value)
	SettingsManager.set_resolution(resolution_option.selected)
	SettingsManager.save_settings()
	SettingsManager.apply()

func _on_back() -> void:
	EventBus.navigate_requested.emit("main_menu")