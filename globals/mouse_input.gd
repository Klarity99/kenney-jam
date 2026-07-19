extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		mouse_press(event)
		
func parse_mouse_press(button_index: int, unit: Node3D, floor_pos: Vector3):
	match button_index:
		MOUSE_BUTTON_LEFT:
			if unit:
				Controls.select_unit(unit)
		MOUSE_BUTTON_RIGHT:
			if Controls.selected_unit and not Controls.selected_unit.building and Controls.selected_unit.ally and not Controls.selected_unit.building:
				if unit:
					unit.select_blink()
				var add_to_queue := Input.is_physical_key_pressed(KEY_SHIFT)
				if unit and not unit.ally:
					Controls.selected_unit.command(floor_pos, "attack", unit, true, add_to_queue)	
				elif unit and unit.id == "hive":
					Controls.selected_unit.command(floor_pos, "to_buidling", unit, true, add_to_queue)
				elif unit and unit.id == "meat":
					Controls.selected_unit.command(floor_pos, "mine", unit, true, add_to_queue)
				else:
					Controls.selected_unit.command(floor_pos, "move", null, true, add_to_queue)

func mouse_press(event :InputEventMouseButton) -> void:
	if not Nodes.game: return
	var camera :Camera3D = get_viewport().get_camera_3d()
	var from :Vector3 = camera.project_ray_origin(event.position)
	var to :Vector3 = from + camera.project_ray_normal(event.position) * 1000
	
	var space_state := Nodes.game.get_world_3d().direct_space_state
	
	
	var floor_query := PhysicsRayQueryParameters3D.create(from, to)
	floor_query.collision_mask = 256
	var floor_result := space_state.intersect_ray(floor_query)
	
	var unit_query := PhysicsRayQueryParameters3D.create(from, to)
	unit_query.collision_mask = 2048
	unit_query.collide_with_areas = true
	var unit_result := space_state.intersect_ray(unit_query)
	
	var floor_pos = floor_result.position if floor_result else null
	var unit = unit_result.collider.get_parent() if unit_result else null
	
	print("---")
	print(floor_pos)
	print(unit)
	
	if not floor_pos and not unit:
		return
	if not floor_pos:
		floor_pos = unit.global_position
	
	parse_mouse_press(event.button_index, unit, floor_pos)
