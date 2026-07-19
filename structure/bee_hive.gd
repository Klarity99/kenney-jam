extends StaticBody3D
class_name BeeHive

@onready var select_view := %SelectView

func _ready() -> void:
	select_view.visible = false
