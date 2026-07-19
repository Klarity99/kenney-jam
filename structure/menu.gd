extends Node3D

@onready var bee_spawner := $BeeSpawner
@onready var bees := $Bees
@onready var play_btn := %Play

const BEE_VIEW := preload("res://Assets/Animals/Bee/animal_bee.tscn")

var bee_nodes := []
var bee_speeds := {}

func _ready() -> void:
	Nodes.menu = self
	bee_spawner.timeout.connect(spawn_bees)
	play_btn.pressed.connect(on_play_btn)
	for i in 30:
		var bee_view := BEE_VIEW.instantiate()
		bees.add_child(bee_view)
		
		bee_view.rotation_degrees.y = 90
		bee_view.global_position = Vector3(randf_range(-30,30), 1, randf_range(-15,15))
		bee_nodes.append(bee_view)
		bee_speeds[bee_view] = randf_range(8.0,12.0)
	
func on_play_btn():
	$AudioStreamPlayer2D.play()
	queue_free()
	add_sibling(load("res://structure/cutscene.tscn").instantiate())
	
func spawn_bees():
	for i in 3:
		var bee_view := BEE_VIEW.instantiate()
		bees.add_child(bee_view)
		
		bee_view.rotation_degrees.y = 90
		bee_view.global_position = Vector3(-30 + randf_range(-5,5), 1, randf_range(-15,15))
		bee_nodes.append(bee_view)
		bee_speeds[bee_view] = randf_range(8.0,12.0)
		
	

func _physics_process(delta: float) -> void:
	var garbage := []
	for bee in bee_nodes:
		bee.position.x += delta * bee_speeds[bee]
		if bee.position.x >= 30.0:
			garbage.append(bee)
			bee.queue_free()
	for bee in garbage:
		bee_nodes.erase(bee)
		bee_speeds.erase(bee)
