class_name EvidenceData
extends Resource

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var miniature: Texture2D = null
@export var photo: Texture2D = null
@export_enum("photo", "document") var category: String = "photo"
@export var unlock_condition: String = ""
@export var record: RecordData = null
