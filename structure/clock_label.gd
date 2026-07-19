extends Label

var total_seconds := 8 * 60
@onready var timer := $Timer

func _ready() -> void:
	timer.timeout.connect(on_timeout)
	timer.start(1.0)
	
func on_timeout():
	total_seconds -= 1
	var minutes := int(total_seconds / 60.0)
	var seconds := total_seconds % 60
	text = "%d:%.2d" % [minutes, seconds]
