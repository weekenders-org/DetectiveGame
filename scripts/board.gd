class_name DetectiveBoard
extends Panel

signal connection_created(from_uid: String, to_uid: String)

@export var note_scene: PackedScene
@export var connection_scene: PackedScene
@export var pin_offset: Vector2 = Vector2(20, 0)

@onready var notes_layer: Node2D = $NotesLayer
@onready var connections_layer: Node2D = $ConnectionsLayer

var active_note: EvidenceNote = null
var current_connection: Line2D = null
var notes: Dictionary = {}  # uid: EvidenceNote

func add_note_from_database(uid: String, texture: Texture2D, metadata: Dictionary, pos: Vector2) -> void:
	if uid in notes:
		notes[uid].position = pos
		return
	
	var note = note_scene.instantiate()
	notes_layer.add_child(note)
	note.setup(uid, texture, metadata)
	note.position = pos
	note.note_moved.connect(_on_note_moved)
	note.connection_started.connect(_on_connection_started)
	note.connection_completed.connect(_on_connection_completed)
	notes[uid] = note

func _on_note_moved(note: EvidenceNote) -> void:
	update_connections(note.uid)

func _on_connection_started(from_note: EvidenceNote, from_position: Vector2) -> void:
	active_note = from_note
	current_connection = connection_scene.instantiate()
	connections_layer.add_child(current_connection)
	current_connection.add_point(from_position)
	current_connection.add_point(get_global_mouse_position())

func _on_connection_completed(from_note: EvidenceNote) -> void:
	if not current_connection: return
	
	var target_note = _get_note_under_mouse()
	if target_note and target_note != from_note:
		create_connection(from_note.uid, target_note.uid)
	
	current_connection.queue_free()
	current_connection = null
	active_note = null

func _input(event: InputEvent) -> void:
	if current_connection and event is InputEventMouseMotion:
		current_connection.set_point_position(1, get_global_mouse_position())

func _get_note_under_mouse() -> EvidenceNote:
	var mouse_pos = get_global_mouse_position()
	for note in notes.values():
		if note.get_global_rect().has_point(mouse_pos):
			return note
	return null

func create_connection(from_uid: String, to_uid: String) -> void:
	var connection = connection_scene.instantiate()
	connections_layer.add_child(connection)
	
	connection.setup(
		notes[from_uid].get_pin_position(),
		notes[to_uid].get_pin_position()
	)
	
	connection_created.emit(from_uid, to_uid)

func update_connections(note_uid: String) -> void:
	for connection in connections_layer.get_children():
		if connection.from_uid == note_uid:
			connection.update_start(notes[note_uid].get_pin_position())
		elif connection.to_uid == note_uid:
			connection.update_end(notes[note_uid].get_pin_position())
