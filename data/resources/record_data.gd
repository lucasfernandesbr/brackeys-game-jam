class_name RecordData
extends Resource

enum RecordType { VICTIM, WRITTEN }

@export var id: String = ""
@export var title: String = ""
@export var miniature: Texture2D = null
@export var record_type: RecordType = RecordType.VICTIM

@export var photo: Texture2D = null
@export var fields: Array[RecordField] = []
@export_multiline var report_body: String = ""
@export var stamp: Texture2D = null
@export var signature: Texture2D = null
