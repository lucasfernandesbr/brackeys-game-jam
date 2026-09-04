@tool
class_name EvidenceList
extends ScrollContainer

func _can_drop_data(_at_pos: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.get("source_slot") != null

func _drop_data(_at_pos: Vector2, data: Variant) -> void:
	(data.source_slot as EvidenceSlot).clear()
	GameState.remove_evidence((data.evidence as EvidenceData).id)
