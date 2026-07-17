extends Node3D


@export var panSpeed : float = 15.0
@export var zoomSpeed : float = 2.0
@export var minZoomScale : float = 4.0
@export var maxZoomScale : float = 25.0

@onready var camera3d : Camera3D = $Camera3D

func _process(delta: float) -> void:
	var movementDirection := Vector3.ZERO
	
	if Input.is_action_pressed("ui_up") or Input.is_physical_key_pressed(KEY_W):
		movementDirection.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_physical_key_pressed(KEY_S):
		movementDirection.z += 1
	if Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A):
		movementDirection.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D):
		movementDirection.x += 1
	
	if movementDirection != Vector3.ZERO:
		movementDirection = movementDirection.normalized()
		position += movementDirection * panSpeed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera3d.position.y = max(camera3d.position.y - zoomSpeed, minZoomScale)
			camera3d.position.z = max(camera3d.position.z - (zoomSpeed * 0.8), (minZoomScale * 0.8))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera3d.position.y = min(camera3d.position.y + zoomSpeed, maxZoomScale)
			camera3d.position.z = min(camera3d.position.z + (zoomSpeed * 0.8), (maxZoomScale * 0.8))
