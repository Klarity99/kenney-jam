extends Node

var main: Node3D
var game: Node3D
var menu: Node3D

var hive: Unit

func _ready() -> void:
	main = get_tree().root.get_node_or_null("Main")
	await get_tree().process_frame
	if Controls.quick_start:
		if menu: menu.queue_free()
	else:
		if game: game.queue_free()
