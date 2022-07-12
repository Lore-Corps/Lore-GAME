extends Node

var timer: float
export(PackedScene) var player_target_node

var target: Node


var number_of_active_targets: int
var number_of_targets_destroyed: int

var game_running: bool = false

var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	pass # Replace with function body.

func _process(delta):
	timer -= delta
	if game_running:
		if timer < 0:
			create_target()
			timer = rng.randf_range(0.5, 0.7)
		number_of_active_targets = get_child_count() -1
		if number_of_active_targets > 10:
			print("You suck")
			game_running = false
			timer = 0.5
			$StartTargetSpawningButton.visible = true
			

#TODO finish this. 
func reset_target_minigame():
	timer = 0.5
	number_of_active_targets = get_child_count() -1

func create_target():
	target = player_target_node.instance()
	add_child(target)
	target.position = Vector2(rng.randf_range(100, 900), rng.randf_range(50, 500))
	print("We created a Target")


func _on_StartTargetSpawningButton_pressed():
	game_running = true
	$StartTargetSpawningButton.visible = false
