extends Node2D

export (PackedScene) var playerScene
export (PackedScene) var enemyScene
export (PackedScene) var reactionScene

var reaction: Node
var player: Node
var enemy: Node


var turn_tracker = []
var turn_counter = 0


var attack_reaction_test_running: bool = false
var delayed_reaction_test_running: bool = false

var battle_on_going: bool

var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
		
	# Creates a player and enemy and adds them to a turn tracker
	create_player()
	create_enemy()
	
	create_reaction_test()
	
	battle_on_going = true
	
	turn_tracker.sort_custom(self, "sort_based_on_agil")
	
	# Uses recursion to cycle turns. 
	take_turn()




func take_turn():
	
	#resets back to the quickest entities turn
	if turn_counter >= 2:
		turn_counter = 0
		
	update_turn_tracker()
	if player == turn_tracker[turn_counter] && turn_tracker[turn_counter].is_alive:
		$BattleCanvasLayer/Actions.visible = true
		
		turn_tracker[turn_counter].my_turn = true
	if enemy == turn_tracker[turn_counter] && turn_tracker[turn_counter].is_alive:
		turn_tracker[turn_counter].my_turn = true

		yield(get_tree().create_timer(2.0), "timeout")
		enemy_logic_for_turn()


func enemy_logic_for_turn():
	if enemy.is_alive:
		rng.randomize()
		var random = rng.randi_range(0, 100)
		print(random)
		if random < 10:
			print("Brad crit")
			player.take_damage(enemy.attack() * 2)
		if random < 75:
			print("brad attacked")
			player.take_damage(enemy.attack())
		else:
			print("brad healed")
			turn_tracker[turn_counter].heal()
		end_turn()


func update_turn_tracker():
	$BattleCanvasLayer/trackTurns.text = str("It is ", turn_tracker[turn_counter].char_name, " turn.")

func end_turn():
	turn_tracker[turn_counter].my_turn = false
	turn_counter += 1
	take_turn()

# The higher Agillity with be first in the Array.
func sort_based_on_agil(a, b):
		if a.agility > b.agility:
			return true
		return false

# pushed Enitiies into the turn tracker
func pus_to_turn_tracking_array(entity):
	turn_tracker.push_back(entity)

func _on_Attack_pressed():
	reaction.type_of_reaction_attack(1)
	if player.my_turn:
		attack_reaction_test_running = true
		reaction.start_timer()



func end_battle():
	battle_on_going = false
	$BattleCanvasLayer/BattleEnd.visible = true
	if player.is_alive:
		$BattleCanvasLayer/BattleEnd/ResetButtonLabel.text = ("You did it!\nYou beat Brad the Madlad and saved the world")
	else:
		$BattleCanvasLayer/BattleEnd/ResetButtonLabel.text = ("Brad the Madlad goes on to kill everyone you love, you could've save everyone... \nBut hey! Think of the benifits of being dead. You no longer have to pay off your debts.")
		

var random_color: Color
var color_timer: float

func _physics_process(delta):
	
	color_timer += delta
	if color_timer > 1:
		random_color = Color(randf(), randf(), randf())
		color_timer = 0
		$TileMap.modulate = random_color
	
	if !$BattleCanvasLayer/BattleEnd.visible:
		if (!enemy.is_alive or !player.is_alive) && battle_on_going:
			end_battle()
		
		if reaction.visible:
			$BattleCanvasLayer/Actions.visible = false
		
		# When the attack button is pressed this goes off once. 
		if attack_reaction_test_running && !reaction.is_running:
			attack_button_attack()
			end_turn()
		if delayed_reaction_test_running && !reaction.is_running:
			delayed_reaction_test_running = false
			yield(get_tree().create_timer(0.00001), "timeout")
			enemy.take_damage(player.attack() / reaction.timer_stopped)
			
			end_turn()



func attack_button_attack():
	attack_reaction_test_running = false
	# Yield is so it can grab the number for timer_stopped. If you remove this, it will report 0 for one frame.
	yield(get_tree().create_timer(0.00001), "timeout")
	print(reaction.timer_stopped)
	if reaction.timer_stopped != 0:
		enemy.take_damage(player.attack() / reaction.timer_stopped)
	else:
		print("you are a god.")
		enemy.take_damage(enemy.curr_health)
		pass

func create_player():
	player = playerScene.instance()
	add_child(player)
	player.position = Vector2(250, 300)
	pus_to_turn_tracking_array(player)
	
func create_enemy():
	enemy = enemyScene.instance()
	add_child(enemy)
	enemy.position = Vector2(800, 300)
	pus_to_turn_tracking_array(enemy)
	
func create_reaction_test():
	reaction = reactionScene.instance()
	print("reaction child created")
	add_child(reaction)
	reaction.position = Vector2(125, 450)


func _on_DelayAttackl_pressed():
	reaction.type_of_reaction_attack(2)
	if player.my_turn:
		delayed_reaction_test_running = true
		reaction.start_timer()

# changes the TileMap's color based on whose turn it currently is.
func _on_trackTurns_draw():
	pass
	#used to change color every turn
	#if player.my_turn:
		#$TileMap.modulate = "ffffff"
	#if enemy.my_turn:
		#$TileMap.modulate = "ff0000"



func _on_Actions_visibility_changed():
	pass # Replace with function body.


func _on_ResetButton_pressed():
	$BattleCanvasLayer/BattleEnd.visible = false
	enemy.reset()
	player.reset()
	turn_tracker.sort_custom(self, "sort_based_on_agil")
	take_turn()
	battle_on_going = true

