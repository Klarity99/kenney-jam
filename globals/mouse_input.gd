extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		mouse_press(event)
		
func parse_mouse_press(button_index: int, unit: Unit, floor_pos: Vector3):
	match button_index:
		MOUSE_BUTTON_LEFT:
			if unit:
				Controls.select_unit(unit)
#			var obj := unit_small if unit_small else unit_big
#			var spell
#			if Controls.action in Data.spells:
#				spell = Data.spells[Controls.action]
#			if obj and (not spell or spell.type == "target") and ("wireframe" not in obj or not obj.wireframe or Controls.action == "nothing"):
#				Controls.select_object(obj)
#			else:
#				Controls.floor_left_click(Vector2(floor_pos.x, floor_pos.z))
		MOUSE_BUTTON_RIGHT:
			if Controls.selected_unit and not Controls.selected_unit.builidng and Controls.selected_unit.ally:
				Controls.selected_unit.command(floor_pos)
#			if Controls.action != "nothing":
#				if Controls.action == "building":
#					Controls.build_preview_canceled.emit()
#					var selected_obj := Controls.selected[0]
#					selected_obj.actions.current_card = selected_obj.data.card
#					Controls.selection_updated.emit()
#				else:
#					Controls.action_closed.emit()
#			else:
#				if unit_small:
#					Controls.right_click(unit_small)
#				else:
#					Controls.floor_right_click(Vector2(floor_pos.x, floor_pos.z))

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
	unit_query.collision_mask = 512
#	unit_query.collide_with_areas = true
	var unit_result := space_state.intersect_ray(unit_query)
	
	var floor_pos = floor_result.position if floor_result else null
#	var unit = unit_result.collider.get_parent().obj if unit_result else null
	var unit = unit_result.collider if unit_result else null
	
	print("---")
	print(floor_pos)
	print(unit)
	
	parse_mouse_press(event.button_index, unit, floor_pos)
