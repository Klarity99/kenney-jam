extends Node3D

@onready var random_walk_timer := $RandomWalk
@export var id: String

func _ready() -> void:
	if id == "elephant":
		await get_tree().process_frame
		get_parent().command(Nodes.hive.global_position, "move_building", Nodes.hive)
	else:
		reset_timer()
		random_walk_timer.timeout.connect(on_random_walk)
	
func reset_timer():
	random_walk_timer.start(randf_range(1.0, 30.0))


func on_random_walk():
	var walk_goal := Vector3(randf_range(-12.0, 12.0), 0.0, randf_range(-12.0, 12.0))
	get_parent().command(global_position + walk_goal, "move", null)
	reset_timer()
