class_name TwineConnection
extends Line2D

@export var color: Color = Color("a38b6d")

var from_uid: String
var to_uid: String

func setup(from_pos: Vector2, to_pos: Vector2) -> void:
	print("setting up twine")
	default_color = color
	self.width = 2.0
	clear_points()
	add_point(from_pos)
	add_point(to_pos)

func update_start(new_pos: Vector2) -> void:
	set_point_position(0, new_pos)

func update_end(new_pos: Vector2) -> void:
	set_point_position(1, new_pos)
