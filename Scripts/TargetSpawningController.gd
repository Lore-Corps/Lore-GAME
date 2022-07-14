extends Node


export(PackedScene) var player_target_node

var target: Node

var timer: float

var number_of_active_targets: int
var number_of_targets_destroyed: int

var game_running: bool = false

var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()


func _process(delta) -> void:
	timer -= delta
	if game_running:
		# Spawns a target at random intervals
		if timer < 0:
			create_target()
			timer = rng.randf_range(0.5, 0.7)
			# easy way to keep track of how maybe targets are active. 
			# Scene currently has a button to start the game, so we -1
		number_of_active_targets = get_child_count() -1
		if number_of_active_targets > 10:
			end_target_minigame()
			

# Does what it says.
# TODO add a negitive if the player fails. The idea we are thinking about is using
# this as a status effect and having the player take big damage on failure.
func end_target_minigame() -> void:
	print("You suck")
	game_running = false
	$StartTargetSpawningButton.visible = true
	for child in get_children():
		if child.name != "StartTargetSpawningButton":
			child.queue_free()
	

# Spawns a target at a random location. 
# TODO maybe make them move at random aswell and Make it not spawn on top of the
# attack and delayed attack button. 
func create_target() -> void:
	target = player_target_node.instance()
	add_child(target)
	target.position = Vector2(rng.randf_range(100, 900), rng.randf_range(50, 500))
	target.connect("target_destroyed", self, "_on_PlayerTarget_target_destroyed")
	print("We created a Target")

# The child button starts the minigame right now, this will be removed in the future
# when we make this start via the enemyEnitity
func _on_StartTargetSpawningButton_pressed() -> void:
	if number_of_targets_destroyed != 0:
		reset_target_minigame()
	game_running = true
	$StartTargetSpawningButton.visible = false

func reset_target_minigame() -> void:
	timer = 0.5
	number_of_active_targets = get_child_count() -1
	number_of_targets_destroyed = 0
	get_parent().get_node("TargetsDestroyedCounterLabel").text = str(number_of_targets_destroyed, " targets destroyed")


func _on_PlayerTarget_target_destroyed() -> void:
	number_of_targets_destroyed += 1
	get_parent().get_node("TargetsDestroyedCounterLabel").text = str(number_of_targets_destroyed, " targets destroyed")
