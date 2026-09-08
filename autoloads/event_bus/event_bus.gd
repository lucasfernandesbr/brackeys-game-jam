extends Node

signal navigate_requested(scene_key: String)
signal case_closed(is_correct: bool)
signal evidence_placed(evidence_id: String)
signal evidence_removed(evidence_id: String)
signal settings_changed
signal ui_click_sfx
