extends Node3D

var stage := 0
@onready var bubble := %ThoughtBubble

var texts := [
	"I spot a bee hive",
	"Gonna taste some honey",
	"Ahh nah, bro",
	"I gotta stop 'im",
	"But I need to scale",
	"Scale my BEESINESS",
]
	
func _ready() -> void:
	update_stage()
	
	
func update_stage() -> void:
	if stage == 2:
		$Stage2Sprite.visible = true
		$Camera3D2.current = true
	if stage == 6:
		queue_free()
		add_sibling(load("res://structure/gameEdited.tscn").instantiate())
		return
	bubble.label.text = texts[stage]
	
func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		stage += 1
		update_stage()