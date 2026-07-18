extends CharacterBody3D
class_name Unit

@onready var view := $View
@onready var select_view := %SelectView
@onready var nav_agent := %NavigationAgent3D
@onready var reach_area: Area3D = $Reach
@onready var seconds_timer: Timer = $SecondsTimer
@onready var floater := %FloaterControl

@export var move_speed := 5.0
@export var id: String
@export var building := false
@export var ally := false
@export var loot: int

var in_reach := []

@export var hp := 10
var hp_max := 10

var carry := 0
var carry_max := 15

var state := "idle"
var last_target_mine: Unit
var target_unit: Unit
var target_floor: Vector3

func _ready() -> void:
	hp_max = hp
	select_view.visible = false
	if reach_area:
		reach_area.body_entered.connect(on_body_entered)
		reach_area.body_exited.connect(on_body_exited)
	if seconds_timer:
		seconds_timer.timeout.connect(on_seconds_timeout)
	if id == "hive":
		Nodes.hive = self
	if floater:
		if id in ["bee", "hive"]:
			floater.visible = false
		else:
			floater.visible = true
	update_floater_hp()
		

signal died

var dead := false

func dmg(amount: int) -> void:
	if dead: return
	hp -= amount
	if hp <= 0:
		dead = true
		queue_free()
		died.emit()
		if not ally:
			var meat_node: Unit = load("res://units/scenes/meat.tscn").instantiate()
			add_sibling(meat_node)
			meat_node.hp = loot
			meat_node.hp_max = loot
			meat_node.view.scale *= loot / 100.0
			meat_node.get_node("CollisionShape3D").shape.radius *= loot / 100.0
			meat_node.global_position = global_position
	update_floater_hp()
	
func update_floater_hp():
	if id not in ["bee", "hive"]:
		floater.bar.value = hp * 100.0 / float(hp_max)

func on_seconds_timeout():
	if state == "mine" and carry < carry_max:
		if last_target_mine:
			last_target_mine.dmg(1)
			set_carry(carry + 1)
			if carry >= carry_max or (not last_target_mine or last_target_mine.hp <= 0):
				command(Nodes.hive.global_position, "move_building", Nodes.hive)
		else:
			change_state("idle")

func set_carry(new_carry):
	carry = new_carry
	if id in ["bee"]:
		if carry == 0:
			floater.visible = false
		else:
			floater.visible = true
			floater.bar.value = carry * 100.0 / float(carry_max)

func command(pos: Vector3, command_type: String, new_target_unit = null):
	target_unit = new_target_unit
	target_floor = pos
	print(target_floor)
	change_state(command_type)

func _physics_process(delta: float) -> void:
	if building:
		return

	if state not in ["move", "move_mine", "move_building", "move_attack"]:
		return

	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
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
			command(Nodes.hive.global_position, "move_building", Nodes.hive)
		else:
			change_state("idle")
		
func change_state(new_state) -> void:
	var old_state := state
	match old_state:
		"mine":
			seconds_timer.stop()
	
	match new_state:
		"attack":
			if target_unit not in in_reach:
				change_state("move_attack")
				return
			explode()
		"mine":
			if carry >= carry_max:
				command(Nodes.hive.global_position, "move_building", Nodes.hive)
				return
			last_target_mine = target_unit
			last_target_mine.died.connect(target_mine_lost.bind(last_target_mine))
			if target_unit not in in_reach:
				change_state("move_mine")
				return
			else:
				seconds_timer.start(1.0)
		"move_building":
			nav_agent.target_position = target_floor
		"move_attack":
			nav_agent.target_position = target_floor
		"move_mine":
			if carry >= carry_max:
				command(Nodes.hive.global_position, "move_building", Nodes.hive)
				return
			nav_agent.target_position = target_floor
		"move":
			nav_agent.target_position = target_floor
	state = new_state
		
func explode():
	target_unit.dmg(10)
	queue_free()

func on_body_entered(body: Node3D) -> void:
	if body == self: return
	in_reach.append(body)
	if body == target_unit and state == "move_building":
		Controls.meat += carry
		set_carry(0)
		if last_target_mine:
			command(last_target_mine.global_position, "mine", last_target_mine)
		else:
			change_state("idle")
	if body == target_unit and state == "move_mine":
		change_state("mine")
	if body == target_unit and state == "move_attack":
		explode()

func on_body_exited(body: Node3D) -> void:
	if body == self: return
	in_reach.erase(body)
	if body == target_unit and state == "mine":
		change_state("idle")
