extends Node

var main: Node3D
var game: Node3D

func _ready() -> void:
	main = get_tree().root.get_node("Main")
	game = main.get_node("Game")
