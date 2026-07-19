extends CanvasLayer

var moneyCount : int = 500

@export var beeSceneRef : PackedScene
@export var bumblebeeSceneRef : PackedScene
@export var waspSceneRef : PackedScene

@onready var moneyLabel : Label = $Control/LabelOfMoney
@onready var panelOfDetail : PanelContainer = $Control/PanelOfDetail
@onready var panelOfBeeHive : PanelContainer = $Control/PanelOfBeeHive


func _ready() -> void:
	updateMoneyUI()
	panelOfDetail.visible = true
	panelOfBeeHive.visible = true
	Controls.honey_updated.connect(updateMoneyUI)
	Nodes.ui = self
	if Controls.quick_start:
		visible = true
	else:
		visible = false

func updateMoneyUI() -> void:
	moneyLabel.text = "Honey: " + str(Controls.honey)

func showDetails(state : String) -> void:
	panelOfBeeHive.visible = true
	panelOfDetail.visible = true
	$Control/PanelOfDetail/VBoxContainer/State.text = "State : " + state

func _on_buy_bee_button_pressed() -> void:
	$AudioStreamPlayer2D.play()
	var costBee := 50
	if Controls.honey < costBee:
		return
	if not beeSceneRef:
		return
	Controls.honey -= costBee
	updateMoneyUI()
	var newBeeSpawn : CharacterBody3D = beeSceneRef.instantiate()
	get_tree().current_scene.get_node("Game/Units").add_child(newBeeSpawn)
	if Nodes.hive:
		var rOffSet := Vector3(randf_range(-2, 2), 0, randf_range(2.5, 2.5))
		newBeeSpawn.global_position = Nodes.hive.global_position + rOffSet
	else:
		newBeeSpawn.global_position = Vector3.ZERO

func _on_buy_bumblebee_button_pressed() -> void:
	$AudioStreamPlayer2D.play()
	var costBee := 100
	if Controls.honey < costBee:
		return
	if not bumblebeeSceneRef:
		return
	Controls.honey -= costBee
	updateMoneyUI()
	var newBeeSpawn : CharacterBody3D = bumblebeeSceneRef.instantiate()
	get_tree().current_scene.get_node("Game/Units").add_child(newBeeSpawn)
	if Nodes.hive:
		var rOffSet := Vector3(randf_range(-2, 2), 0, randf_range(2.5, 2.5))
		newBeeSpawn.global_position = Nodes.hive.global_position + rOffSet
	else:
		newBeeSpawn.global_position = Vector3.ZERO

func _on_buy_wasp_button_pressed() -> void:
	$AudioStreamPlayer2D.play()
	var costBee := 75
	if Controls.honey < costBee:
		return
	if not waspSceneRef:
		return
	Controls.honey -= costBee
	updateMoneyUI()
	var newBeeSpawn : CharacterBody3D = waspSceneRef.instantiate()
	get_tree().current_scene.get_node("Game/Units").add_child(newBeeSpawn)
	if Nodes.hive:
		var rOffSet := Vector3(randf_range(-2, 2), 0, randf_range(2.5, 2.5))
		newBeeSpawn.global_position = Nodes.hive.global_position + rOffSet
	else:
		newBeeSpawn.global_position = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		panelOfDetail.visible = true
		panelOfBeeHive.visible = true
