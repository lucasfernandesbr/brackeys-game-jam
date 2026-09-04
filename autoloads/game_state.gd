extends Node

const DEFAULT_CASE_PATH := "res://data/cases/case_stub.tres"
const SAVE_PATH := "user://savegame.cfg"

var current_case: CaseData = null
var current_case_path: String = ""
var placed_evidence_ids: Array[String] = []
var satisfied_conditions: Array[String] = []
var printed_evidence_ids: Array[String] = []
var slot_assignments: Dictionary = {}
var phone_answered: bool = false
var email_read: bool = false

func start_case(case_data: CaseData) -> void:
	current_case = case_data
	current_case_path = case_data.resource_path if case_data != null else ""
	placed_evidence_ids.clear()
	satisfied_conditions.clear()
	slot_assignments.clear()
	printed_evidence_ids.clear()

func new_game(case_data: CaseData) -> void:
	current_case = case_data
	current_case_path = case_data.resource_path if case_data != null else ""
	placed_evidence_ids.clear()
	satisfied_conditions.clear()
	slot_assignments.clear()
	printed_evidence_ids.clear()
	phone_answered = false
	email_read = false
	save_game()

func is_evidence_available(ev: EvidenceData) -> bool:
	return ev.unlock_condition == "" or ev.unlock_condition in satisfied_conditions

func mark_printed(id: String) -> void:
	if id not in printed_evidence_ids:
		printed_evidence_ids.append(id)
		save_game()

func is_printed(id: String) -> bool:
	return id in printed_evidence_ids

func unlock_condition(flag: String) -> void:
	if flag != "" and flag not in satisfied_conditions:
		satisfied_conditions.append(flag)

func place_evidence(id: String, slot_id: String) -> void:
	if id not in placed_evidence_ids:
		placed_evidence_ids.append(id)
	slot_assignments[slot_id] = id
	EventBus.evidence_placed.emit(id)
	save_game()

func remove_evidence(id: String) -> void:
	placed_evidence_ids.erase(id)
	for slot_id in slot_assignments.keys():
		if slot_assignments[slot_id] == id:
			slot_assignments.erase(slot_id)
	EventBus.evidence_removed.emit(id)
	save_game()

func evaluate() -> bool:
	if current_case == null:
		return false
	var required: Array[String] = current_case.correct_evidence_ids
	for req_id in required:
		if req_id not in placed_evidence_ids:
			EventBus.case_closed.emit(false)
			return false
	var exact: bool = placed_evidence_ids.size() == required.size()
	EventBus.case_closed.emit(exact)
	return exact

func reset() -> void:
	placed_evidence_ids.clear()
	satisfied_conditions.clear()
	slot_assignments.clear()
	printed_evidence_ids.clear()

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("case", "current_case_path", current_case_path)
	cfg.set_value("case", "phone_answered", phone_answered)
	cfg.set_value("case", "email_read", email_read)
	cfg.set_value("board", "placed_evidence_ids", placed_evidence_ids)
	cfg.set_value("board", "satisfied_conditions", satisfied_conditions)
	cfg.set_value("board", "slot_assignments", slot_assignments)
	cfg.set_value("board", "printed_evidence_ids", printed_evidence_ids)
	cfg.save(SAVE_PATH)

func load_game() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false
	current_case_path = cfg.get_value("case", "current_case_path", DEFAULT_CASE_PATH)
	phone_answered = cfg.get_value("case", "phone_answered", false)
	email_read = cfg.get_value("case", "email_read", false)
	if current_case_path != "":
		current_case = load(current_case_path)
	var ids: Array = cfg.get_value("board", "placed_evidence_ids", [])
	placed_evidence_ids.assign(ids)
	var conds: Array = cfg.get_value("board", "satisfied_conditions", [])
	satisfied_conditions.assign(conds)
	slot_assignments = cfg.get_value("board", "slot_assignments", {})
	var printed: Array = cfg.get_value("board", "printed_evidence_ids", [])
	printed_evidence_ids.assign(printed)
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
