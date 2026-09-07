extends Control


func _ready() -> void:
	var data: RecordData = load("res://data/records/record_stub.tres")

	$RecordSheet.setup(data)
