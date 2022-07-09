extends Node2D

export(PackedScene) var player_scene
export(PackedScene) var enemy_scene

signal dumb_garbage

var reaction: Node

var good_battlers: Array
var evil_battlers: Array
var all_battlers: Array

var MAXIMUM_TEAM_SIZE: int = 3

var attack_reaction_test_running: bool = false
var delayed_reaction_test_running: bool = false

var random_color: Color
var color_timer: float

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	# For loop executes 3 times and registers players, x var does nothing
	for x in 3:
		register_battler(player_scene)
		register_battler(enemy_scene)

	construct_scene()
	start_battle()


# Turns PackedScenes into instances and pushes them to the team arrays
func register_battler(battler: PackedScene) -> void:
	var battler_instance = battler.instance()
	if good_battlers.size() <= MAXIMUM_TEAM_SIZE:
		if battler_instance.alignment == "good":
			good_battlers.push_front(battler_instance)
		elif battler_instance.alignment == "evil":
			evil_battlers.push_front(battler_instance)
		else:
			push_error(str("Invalid Battler Alignment -> ", battler_instance))
	else:
		push_error(str("Maximum team size already reached"))


# Places PackedScene instances into the battle scene
func construct_scene() -> void:
	# Add battlers to scene
	var offset = 100
	var x_coord_good_team = 300
	var x_coord_bad_team = 700
	var y_coord = 300

	good_battlers.sort_custom(self, "sort_by_agility")
	evil_battlers.sort_custom(self, "sort_by_agility")

	for battler in good_battlers:
		self.add_child(battler)
		battler.position = Vector2(x_coord_good_team, y_coord)
		x_coord_good_team -= offset

	for battler in evil_battlers:
		self.add_child(battler)
		battler.position = Vector2(x_coord_bad_team, y_coord)
		x_coord_bad_team += offset

	reaction = $ReactionTest


# Starts the battle and manages the turn order
func start_battle() -> void:
	all_battlers = good_battlers + evil_battlers
	all_battlers.sort_custom(self, "sort_by_agility")

	while not is_team_dead(good_battlers) and not is_team_dead(evil_battlers):
		for battler in all_battlers:
			update_turn_tracker_label(battler)

			print(battler.char_name, "s turn -------------")

			if battler.is_alive == true:
				battler.activate()

				if battler.alignment == "good":
					$BattleCanvasLayer/Actions.visible = true
					yield(self, "dumb_garbage")

				if battler.alignment == "evil":
					$BattleCanvasLayer/Actions.visible = false
					ai_logic_for_turn(battler)
					yield(get_tree().create_timer(1.0), "timeout")

				battler.deactivate()


# Governs AI turn logic, gives a random AI decision for a battler
func ai_logic_for_turn(battler) -> void:
	var target: BattleEntity = find_front_target(good_battlers)
	print(str(target) + " target")
	if target != null:
		rng.randomize()
		var random = rng.randi_range(0, 100)

		if random < 10:
			print("Brad crit")
			target.take_damage(battler.get_strength() * 2)
		if random < 75:
			print("brad attacked")
			target.take_damage(battler.get_strength())
		else:
			print("brad healed")
			battler.heal()


# Finds the front target on a team
# Probably refactor to combine with find_active_target
func find_front_target(team: Array) -> BattleEntity:
	var target: int = 0
	var has_not_found_target: bool = true

	while has_not_found_target:
		if team[target].is_alive:
			return team[target]
		else:
			if target >= team.size():
				return null
			else:
				target += 1

	return null


# Finds the active target on a team
# Idk if this works for enemies?
func find_active_target(team: Array) -> BattleEntity:
	var target: int = 0
	var has_not_found_target: bool = true

	while has_not_found_target:
		if team[target].is_active:
			return team[target]
		else:
			if target >= team.size():
				return null
			else:
				target += 1

	return null


func update_turn_tracker_label(battler) -> void:
	$BattleCanvasLayer/TurnTrackerLabel.text = str("It is ", battler.char_name, " turn.")


# The higher Agillity with be first in the Array.
func sort_by_agility(a: BattleEntity, b: BattleEntity) -> bool:
	if a.agility > b.agility:
		return true
	return false


func _on_Attack_pressed() -> void:
	reaction.type_of_reaction_attack(1)
	if find_active_target(good_battlers).is_active:
		attack_reaction_test_running = true
		reaction.start_timer()


func end_battle() -> void:
	$BattleCanvasLayer/BattleEnd.visible = true
	if !is_team_dead(good_battlers):
		$BattleCanvasLayer/BattleEnd/ResetButtonLabel.text = ("You did it!\nYou beat Brad the Madlad and saved the world")
	else:
		$BattleCanvasLayer/BattleEnd/ResetButtonLabel.text = ("Brad the Madlad goes on to kill everyone you love, you could've save everyone... \nBut hey! Think of the benifits of being dead. You no longer have to pay off your debts.")


func _physics_process(delta) -> void:
	color_timer += delta
	if color_timer > 1:
		random_color = Color(randf(), randf(), randf())
		color_timer = 0
		$TileMap.modulate = random_color

	if !$BattleCanvasLayer/BattleEnd.visible:
		if is_team_dead(good_battlers) or is_team_dead(evil_battlers):
			end_battle()

		if reaction.visible:
			$BattleCanvasLayer/Actions.visible = false

		# When the attack button is pressed this goes off once.
		if attack_reaction_test_running && !reaction.is_running:
			attack_button_attack()
			#battler_turn_index += 1
		if delayed_reaction_test_running && !reaction.is_running:
			delayed_reaction_test_running = false
			yield(get_tree().create_timer(0.00001), "timeout")
			find_front_target(evil_battlers).take_damage(
				find_front_target(good_battlers).get_strength() / reaction.timer_stopped
			)

			#battler_turn_index += 1


func is_team_dead(team) -> bool:
	var dead_count = 0
	for battler in team:
		if battler.is_alive == false:
			dead_count += 1
	if dead_count >= team.size():
		return true
	else:
		return false


func attack_button_attack() -> void:
	attack_reaction_test_running = false
	# Yield is so it can grab the number for timer_stopped. If you remove this, it will report 0
	# for one frame.
	yield(get_tree().create_timer(0.00001), "timeout")
	print(reaction.timer_stopped)
	if reaction.timer_stopped != 0:
		find_front_target(evil_battlers).take_damage(
			find_front_target(good_battlers).get_strength() / reaction.timer_stopped
		)
	else:
		print("you are a god.")
		find_front_target(evil_battlers).current_health = 0
		pass


func _on_DelayAttackl_pressed() -> void:
	reaction.type_of_reaction_attack(2)
	if find_active_target(good_battlers).is_active:
		delayed_reaction_test_running = true
		reaction.start_timer()


func _on_Actions_visibility_changed() -> void:
	pass  # Replace with function body.


func _on_ResetButton_pressed() -> void:
	$BattleCanvasLayer/BattleEnd.visible = false
	for battler in all_battlers:
		battler.queue_free()
	#battler_turn_index = 0
	good_battlers = []
	evil_battlers = []
	all_battlers = []
	_ready()


func _on_ReactionTest_reaction_test_done():
	emit_signal("dumb_garbage")
