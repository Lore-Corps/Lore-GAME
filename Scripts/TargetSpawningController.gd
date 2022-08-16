extends Node


export(PackedScene) var player_target_node

var target: Node

var target_spawn_timer := Timer.new()

var number_of_active_targets: int
export var max_targets_till_failure = 10

var game_running: bool = false

var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	create_target_timer()


func _process(_delta) -> void:


	if game_running:
		# Sets a time for a target to be spawned in.
		# When the timer runs out it calls _on_timer_timeout()
		if target_spawn_timer.is_stopped() == true:
			target_spawn_timer.set_wait_time(rng.randf_range(0.7, 1))
			target_spawn_timer.start()
		# easy way to keep track of how maybe targets are active. 
		# the -1 is for the Timer that is always an child 
		number_of_active_targets = get_child_count() -1
		if number_of_active_targets >= 10:
			end_target_minigame()

func create_target_timer() -> void:
	add_child(target_spawn_timer, true)
	target_spawn_timer.connect("timeout", self, "_on_timer_timeout")
	target_spawn_timer.one_shot = true

func start_target_minigame() -> void:
	game_running = true


func _on_timer_timeout():
	# It kept spawning a target after the games ends, and I'm trying to debug 
	# something else right now. SO STOP ANNOYING ME BITCH
	if game_running:
		create_target()


# Does what it says.
# TODO add a negitive if the player fails. The idea we are thinking about is using
# this as a status effect and having the player take big damage on failure.
func end_target_minigame() -> void:
	game_running = false
	for child in get_children():
		if child.name != "Timer":
			child.queue_free()

# TODO maybe make them move at random aswell and Make it not spawn on top of the
# attack and delayed attack button. 
func create_target() -> void:
	target = player_target_node.instance()
	add_child(target)
	target.position = Vector2(rng.randf_range(100, 900), rng.randf_range(50, 500))


func reset_target_minigame() -> void:
	number_of_active_targets = get_child_count() -1
	
