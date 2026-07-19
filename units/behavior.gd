extends Node3D

@onready var random_walk_timer := $RandomWalk
@onready var vision_area := get_node_or_null("Vision")
@export var id: String

var wasps := []

func _ready() -> void:
	if id == "elephant":
		await get_tree().process_frame
		get_parent().command(Nodes.hive.global_position, "to_buidling", Nodes.hive)
	else:
		reset_timer()
		random_walk_timer.timeout.connect(on_random_walk)
		vision_area.body_entered.connect(on_body_entered)
		vision_area.body_exited.connect(on_body_exited)
	
func reset_timer():
	random_walk_timer.start(randf_range(1.0, 30.0 if wasps.is_empty() else 10.0))

func on_random_walk():
	var walk_goal: Vector3

	if not wasps.is_empty():
		var away_direction := Vector3.ZERO

		for wasp in wasps:
			if is_instance_valid(wasp):
				away_direction += global_position.direction_to(wasp.global_position) * -1.0

		if away_direction.length_squared() > 0.01:
			away_direction = away_direction.normalized()
			walk_goal = away_direction * randf_range(5.0, 10.0)
		else:
			walk_goal = Vector3.ZERO
	else:
		walk_goal = Vector3(
			randf_range(-12.0, 12.0),
			0.0,
			randf_range(-12.0, 12.0)
		)

	get_parent().command(global_position + walk_goal, "move", null)
	reset_timer()

func on_body_entered(body: Node3D):
	if body is Unit and body.id == "wasp":
		wasps.append(body)
		if random_walk_timer.time_left > 4.0:
			random_walk_timer.start(1.0)

func on_body_exited(body: Node3D):
	if body is Unit and body.id == "wasp":
		wasps.erase(body)
