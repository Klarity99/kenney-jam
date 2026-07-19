extends Node3D

@onready var honey_collectible_timer := $HoneyCollectibleTimer

const HONEY_COLLECTIBLE := preload("res://structure/honey_collectible.tscn")

func _ready() -> void:
	Nodes.game = self
	honey_collectible_timer.start(4.0)
	honey_collectible_timer.timeout.connect(on_honey_collectible_timer)

func on_honey_collectible_timer():
	var honey_collectible := HONEY_COLLECTIBLE.instantiate()
	$Units.add_child(honey_collectible)
	honey_collectible.global_position = Vector3(randf_range(-50.0,50.0), 0.0, randf_range(-50.0,50.0))
	