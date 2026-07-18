extends CanvasLayer

var moneyCount : int = 500

@export var beeSceneRef : PackedScene

@onready var moneyLabel : Label = $Control/LabelOfMoney
@onready var panelOfDetail : PanelContainer = $Control/PanelOfDetail
@onready var panelOfBeeHive : PanelContainer = $Control/PanelOfBeeHive

func _ready() -> void:
	updateMoneyUI()
	panelOfDetail.visible = false
	panelOfBeeHive.visible = false

func updateMoneyUI() -> void:
	moneyLabel.text = "Money : " + str(moneyCount)

func showDetails(state : String) -> void:
	panelOfBeeHive.visible = true
	panelOfDetail.visible = true
	$Control/PanelOfDetail/VBoxContainer/State.text = "State : " + state

func _on_buy_bee_button_pressed() -> void:
	var costBee := 50
	if moneyCount < costBee:
		return
	if not beeSceneRef:
		return
	moneyCount -= costBee
	updateMoneyUI()
	var newBeeSpawn : CharacterBody3D = beeSceneRef.instantiate()
	get_tree().current_scene.get_node("Game/Units").add_child(newBeeSpawn)
	if Nodes.hive:
		var rOffSet := Vector3(randf_range(-2, 2), 0, randf_range(-2, -2))
		newBeeSpawn.global_position = Nodes.hive.global_position + rOffSet
	else:
		newBeeSpawn.global_position = Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		panelOfDetail.visible = false
		panelOfBeeHive.visible = false
