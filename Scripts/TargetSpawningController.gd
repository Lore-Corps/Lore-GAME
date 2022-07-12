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
		
		if timer < 0:
			create_target()
			timer = rng.randf_range(0.5, 0.7)
			
		number_of_active_targets = get_child_count() -1
		if number_of_active_targets > 10:
			end_target_minigame()
			

func end_target_minigame() -> void:
	print("You suck")
	game_running = false
	$StartTargetSpawningButton.visible = true
	for child in get_children():
		if child.name != "StartTargetSpawningButton":
			child.queue_free()
	


func create_target() -> void:
	target = player_target_node.instance()
	add_child(target)
	target.position = Vector2(rng.randf_range(100, 900), rng.randf_range(50, 500))
	target.connect("target_destroyed", self, "_on_PlayerTarget_target_destroyed")
	print("We created a Target")


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
