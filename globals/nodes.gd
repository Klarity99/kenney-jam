extends Node

var main: Node3D
var game: Node3D

var hive: Unit

func _ready() -> void:
	main = get_tree().root.get_node_or_null("Main")
	if main:
		game = main.get_node("Game")
