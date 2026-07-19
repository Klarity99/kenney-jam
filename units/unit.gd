extends CharacterBody3D
class_name Unit

@onready var view := $View
@onready var select_view := %SelectView
@onready var nav_agent := get_node_or_null("NavigationAgent3D")
@onready var reach_area: Area3D = get_node_or_null("Reach")
@onready var seconds_timer: Timer = get_node_or_null("SecondsTimer")
@onready var floater := %FloaterControl
@onready var behavior := get_node_or_null("Behavior")

@export var move_speed := 5.0
@export var id: String
@export var building := false
@export var ally := false
@export var loot: int
@export var animation : AnimationPlayer

@export var gameWonScene : PackedScene

var in_reach := []

@export var hp := 10
var hp_max := 10

var carry := 0
@export var carry_max := 20

var state := "idle"
var last_target_mine: Unit
var target_unit: Unit
var target_floor: Vector3

var ui : CanvasLayer

func _ready() -> void:
	hp_max = hp
	select_view.visible = false
	if reach_area:
		reach_area.body_entered.connect(on_body_entered)
		reach_area.body_exited.connect(on_body_exited)
		reach_area.area_entered.connect(on_area_entered)
	if seconds_timer:
		seconds_timer.timeout.connect(on_seconds_timeout)
	if id == "hive":
		Nodes.hive = self
	if floater:
		if id in ["bee", "hive", "bumblebee"]:
			floater.visible = false
		else:
			floater.visible = true
	update_floater_hp()
	animationLoop("idle", true)
	animationLoop("run", true)
	animationLoop("eat", true)
	playAnimation("idle")

signal died

var dead := false

func dmg(amount: int) -> void:
	if dead: return
	hp -= amount
	if hp <= 0:
		if name == "Elephant":
			gameWonScene = preload("res://structure/victory_ui.tscn")
			var newScene = gameWonScene.instantiate()
			get_tree().current_scene.get_node("Game").add_child(newScene)
		dead = true
		queue_free()
		died.emit()
		if not ally:
			var meat_node: Unit = load("res://units/scenes/meat.tscn").instantiate()
			add_sibling(meat_node)
			meat_node.hp = loot
			meat_node.hp_max = loot
			meat_node.view.scale *= loot / 200.0
			meat_node.get_node("CollisionShape3D").shape.radius *= loot / 200.0
			meat_node.global_position = global_position
	update_floater_hp()

func select_blink():
	select_view.visible = !select_view.visible
	await get_tree().create_timer(0.2).timeout
	select_view.visible = is_selected()

func is_selected():
	return Controls.selected_unit == self

func update_floater_hp():
	if id not in ["bee", "hive", "bumblebee", "wasp"]:
		floater.bar.visible = hp < hp_max
		floater.bar.value = hp * 100.0 / float(hp_max)

func animationLoop(animationName: String, loopFlag: bool):
	if not animation:
		return
	if animation.has_animation(animationName):
		var currentAnimation := animation.get_animation(animationName)
		currentAnimation.loop_mode = Animation.LOOP_LINEAR if loopFlag else Animation.LOOP_NONE
	else:
		print("Current Animation error not found", animationName)

func playAnimation(animationName: String) -> void:
	if not animation:
		return
	if animation and animation.has_animation(animationName):
		animation.play(animationName, -1.0, 1.0 if id != "elephant" else 0.01)

func on_seconds_timeout():
	if state == "mine" and carry < carry_max:
		if last_target_mine:
			last_target_mine.dmg(1)
			set_carry(carry + 1)
			if carry >= carry_max or (not last_target_mine or last_target_mine.hp <= 0):
				command(Nodes.hive.global_position, "to_buidling", Nodes.hive)
		else:
			change_state("idle")

func set_carry(new_carry):
	carry = new_carry
	carry = min(carry, carry_max)
	if id in ["bee", "bumblebee", "wasp"]:
		if carry == 0:
			floater.visible = false
		else:
			floater.visible = true
			floater.bar.value = carry * 100.0 / float(carry_max)

func command(pos: Vector3, command_type: String, new_target_unit = null):
	target_unit = new_target_unit
	target_floor = pos
	change_state(command_type)

func _physics_process(_delta: float) -> void:
	if building:
		return

	if state not in ["move", "move_mine", "move_building", "move_attack"]:
		return

	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		if state == "move":
			change_state("idle")
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var dir: Vector3 = (next_pos - global_position).normalized()

	velocity = dir * move_speed
	move_and_slide()

	if dir.length_squared() > 0.001:
		view.look_at(global_position + dir, Vector3.UP)
	
func target_mine_lost(target_mine) -> void:
	if target_mine != last_target_mine: return
	if state in ["mine", "move_mine"]:
		if carry > 0:
			command(Nodes.hive.global_position, "to_buidling", Nodes.hive)
		else:
			change_state("idle")
		
func change_state(new_state) -> void:
	var old_state := state
	match old_state:
		"mine":
			seconds_timer.stop()
	
	match new_state:
		"idle":
			playAnimation("idle")
		"move":
			playAnimation("run")
		"move_mine":
			playAnimation("run")
		"move_building", "to_buidling":
			playAnimation("run")
		"move_attack":
			playAnimation("run")
		"attack":
			playAnimation("eat")
		"mine":
			playAnimation("eat")
	match new_state:
		"attack":
			if target_unit not in in_reach:
				change_state("move_attack")
				return
			explode()
		"to_buidling":
			if target_unit not in in_reach:
				change_state("move_building")
				return
			to_building()
		"mine":
			if carry >= carry_max:
				command(Nodes.hive.global_position, "to_buidling", Nodes.hive)
				return
			last_target_mine = target_unit
			last_target_mine.died.connect(target_mine_lost.bind(last_target_mine))
			if target_unit not in in_reach:
				change_state("move_mine")
				return
			else:
				seconds_timer.start(1.0)
		"move_building":
			if target_floor != null:
				nav_agent.target_position = target_floor
		"move_attack":
			if target_floor != null:
				nav_agent.target_position = target_floor
		"move_mine":
			if carry >= carry_max:
				command(Nodes.hive.global_position, "to_buidling", Nodes.hive)
				return
			if target_floor != null:
				nav_agent.target_position = target_floor
		"move":
			if target_floor != null:
				nav_agent.target_position = target_floor
	state = new_state
		
func to_building():
	Controls.set_honey(Controls.honey + carry)
	set_carry(0)
	if last_target_mine:
		command(last_target_mine.global_position, "mine", last_target_mine)
	else:
		change_state("idle")
		
func explode():
	target_unit.dmg(hp) # hp for bees count as damage
	$AudioStreamPlayer2D.play()

func on_body_entered(body: Node3D) -> void:
	if body == self: return
	in_reach.append(body)
	if body == target_unit and state == "move_building":
		to_building()
	if body == target_unit and state == "move_mine":
		change_state("mine")
	if body == target_unit and state == "move_attack":
		explode()

func on_body_exited(body: Node3D) -> void:
	if body == self: return
	in_reach.erase(body)
	if body == target_unit and state == "mine":
		if (name.contains("Bee") or name.contains("Bumblebee") or name.contains("Wasp")) and !name.contains("Hive"):
			animation.play("idle")
		change_state("idle")

func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		get_viewport().set_input_as_handled()
		ui = get_tree().current_scene.get_node("UI")
		ui.visible = true
		if ui:
			ui.showDetails(state)

func on_area_entered(area: Area3D):
	if area.get_parent() is HoneyCollectible:
		set_carry(carry + 8)
		area.get_parent().queue_free()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
