extends Control

@onready var close_btn := $CloseBtn

func _ready() -> void:
	if Controls.quick_start:
		visible = false
	else:
		visible = true
	close_btn.pressed.connect(func(): visible = false)
	

func open() -> void:
	visible = true


func toggle() -> void:
	visible = not visible
