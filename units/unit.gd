extends Node3D
class_name Unit

@onready var select_view := %SelectView
@onready var nav_agent := $NavigationAgent3D

@export var move_speed := 5.0
@export var id: String
@export var builidng := false
@export var ally := false

var hp := 10

func _ready() -> void:
	select_view.visible = false

func command(pos: Vector3):
	nav_agent.target_position = pos

func _physics_process(delta: float) -> void:
	if builidng: return
	if nav_agent.is_navigation_finished():
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var dir: Vector3 = global_position.direction_to(next_pos)

	global_position += dir * move_speed * delta

	# Optional: face movement direction
	if dir.length_squared() > 0.001:
		look_at(global_position + dir, Vector3.UP)
		
