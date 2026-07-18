extends Node

var selected_unit: Unit

func select_unit(new_selected_unit: Unit):
	print("selected", new_selected_unit)
	if selected_unit:
		selected_unit.select_view.visible = false
	selected_unit = new_selected_unit
	selected_unit.select_view.visible = true
