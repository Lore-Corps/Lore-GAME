extends Node2D

# ----- signals -----
# ----- enums -----
# ----- constants -----
# Must be greater than 0
var MAXIMUM_TEAM_SIZE: int = 1

# ----- exported vars -----
export(PackedScene) var player_scene
export(PackedScene) var enemy_scene

# ----- public vars -----
var is_active: bool
var reaction_test: Node
var reaction_test_delta: float
var good_battlers: Array
var evil_battlers: Array
var all_battlers: Array
var random_color: Color
var color_timer: float
var rng := RandomNumberGenerator.new()

# ----- private vars -----
# ----- onready vars -----


# ----- built-in virtual _ready method -----
func _ready() -> void:
	#start_scene()
	pass


# ----- remaining built-in virtual methods -----
func _process(delta) -> void:
	color_timer += delta
	if color_timer > 1:
		random_color = Color(randf(), randf(), randf())
		color_timer = 0
		$TileMap.modulate = random_color


# ----- public methods -----


func start_scene() -> void:
	# For loop executes 3 times and registers players, x var does nothing
	is_active = true
	for x in MAXIMUM_TEAM_SIZE:
		register_battler(player_scene)
		register_battler(enemy_scene)
	construct_scene()
	start_battle()


# Turns PackedScenes into instances and pushes them to the team arrays
func register_battler(battler: PackedScene) -> void:
	var battler_instance = battler.instance()
	if battler_instance.alignment == "good":
		if good_battlers.size() < MAXIMUM_TEAM_SIZE:
			good_battlers.push_front(battler_instance)
		else:
			push_error(str("Maximum good team size already reached"))
	elif battler_instance.alignment == "evil":
		if evil_battlers.size() < MAXIMUM_TEAM_SIZE:
			evil_battlers.push_front(battler_instance)
		else:
			push_error(str("Maximum good team size already reached"))
	else:
		push_error(str("Invalid Battler Alignment -> ", battler_instance))


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

	self.visible = true
	for child in $BattleUI.get_children():
		child.visible = true
	$TileMap.visible = true
	$BattleUI/BattleEnd.visible = false
	reaction_test = $ReactionTest


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

				# For some reason the yields have to be in this function in order
				# to work. idk why.

				# Player Turn
				if battler.alignment == "good":
					$BattleUI/PlayerActions.visible = true
					yield($ReactionTest, "reaction_test_done")
					player_logic_for_turn(battler)

				# Evil Turn
				if battler.alignment == "evil":
					$BattleUI/PlayerActions.visible = false
					yield(get_tree().create_timer(1.0), "timeout")
					ai_logic_for_turn(battler)

				if is_team_dead(good_battlers) or is_team_dead(evil_battlers):
					win_battle(battler)

				battler.deactivate()


# Governs AI turn logic, gives a random AI decision for a battler
func ai_logic_for_turn(battler) -> void:
	var target: BattleEntity = find_front_target(good_battlers)
	if target != null:
		rng.randomize()
		var random = rng.randi_range(0, 100)

		if random < 10:
			print("Brad crit")
			target.take_damage(battler.get_strength() * 2)
		if random < 80:
			print("brad attacked")
			target.take_damage(battler.get_strength())
		else:
			print("brad healed")
			battler.heal()


# Governs Player turn logic
func player_logic_for_turn(battler) -> void:
	reaction_test_delta = reaction_test.timestamp_delta
	find_front_target(evil_battlers).take_damage(battler.calculate_damage(reaction_test_delta))


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


func win_battle(winning_team_member: BattleEntity) -> void:
	$BattleUI/BattleEnd.visible = true
	if winning_team_member.alignment == "good":
		$BattleUI/BattleEnd/ResetButtonLabel.text = ("You did it!\nYou beat Brad the Madlad and saved the world")
	elif winning_team_member.alignment == "evil":
		$BattleUI/BattleEnd/ResetButtonLabel.text = ("Brad the Madlad goes on to kill everyone you love, you could've saved everyone... \nBut hey! Think of the benefits of being dead. You no longer have to pay off your debts.")


func is_team_dead(team) -> bool:
	var dead_count = 0
	for battler in team:
		if battler.is_alive == false:
			dead_count += 1
	if dead_count >= team.size():
		return true
	else:
		return false


# ----- private methods -----
func _on_AttackButton_pressed() -> void:
	$BattleUI/PlayerActions.visible = false
	if find_active_target(all_battlers).alignment == "good":
		reaction_test.start()


func _on_AttackButtonDelayed_pressed() -> void:
	$BattleUI/PlayerActions.visible = false
	if find_active_target(good_battlers).is_active:
		reaction_test.start(2)


func _on_ResetButton_pressed() -> void:
	self.visible = false
	for child in $BattleUI.get_children():
		child.visible = false
	$BattleUI/BattleEnd.visible = false
	$TileMap.visible = false
	for battler in all_battlers:
		battler.queue_free()
	good_battlers = []
	evil_battlers = []
	all_battlers = []
	_ready()
	# dumb yield to prevent another battle within 3 seconds
	#yield(get_tree().create_timer(3.0), "timeout")
	is_active = false


# The higher Agillity with be first in the Array.
func sort_by_agility(a: BattleEntity, b: BattleEntity) -> bool:
	if a.agility > b.agility:
		return true
	return false


func update_turn_tracker_label(battler) -> void:
	$BattleUI/TurnTrackerLabel.text = str("It is ", battler.char_name, " turn.")
