extends Node

var quick_start := false

var selected_unit: Unit
var meat := 0

func select_unit(new_selected_unit: Unit):
	if selected_unit:
		selected_unit.select_view.visible = false
	selected_unit = new_selected_unit
	selected_unit.select_view.visible = true
