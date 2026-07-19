extends Node

var quick_start := true

var selected_unit: Unit
var honey := 50

signal honey_updated

func select_unit(new_selected_unit: Unit):
	if selected_unit:
		selected_unit.select_view.visible = false
	selected_unit = new_selected_unit
	selected_unit.select_view.visible = true

func set_honey(new_honey: int):
	honey = new_honey
	honey_updated.emit()
