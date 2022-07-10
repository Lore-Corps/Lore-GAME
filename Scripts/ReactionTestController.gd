extends Node

signal reaction_test_done

var timer: float
#Time when timer stopped. Attack types edit this when sending it to the battleController
var reaction_delta: float

var is_running: bool = false
var target_time: float

# Show "CRITICAL FAILURE!" on the ui to indicate button will vanish soon
# this is if the player waits too long without hitting the button
var critical_failure_time: float

var time_until_invisible: int = 1

# 0 is no attack. 1 is attack. 2 is delayed attack
var type_of_attack: int


var delayed_wait: int = 2

var random_target_time = RandomNumberGenerator.new()

var invisible_timer: float


func _ready():
	set_target_time()
	self.visible = false


func set_target_time():
	random_target_time.randomize()
	target_time = random_target_time.randf_range(0.4, 5)
	critical_failure_time = target_time + 2.7
	#This was just for testing
	#target_time = 2


func _physics_process(delta):
	if is_running:
		timer += delta
	if is_running:
		if type_of_attack == 2:
			$ReactionLabel.text = str("React after ", delayed_wait, " seconds")
	if timer >= target_time:
		$ReactionButton.modulate = "bb4444"
	if not is_running and timer > 0.0001 and type_of_attack == 1:
		reaction_delta = (timer - target_time) * .75
		$ReactionLabel.text = str("You reacted in ", stepify(reaction_delta, .001))
		turn_invisible(delta)
	if not is_running and timer > 0.0001 and type_of_attack == 2:
		reaction_delta = timer - target_time - delayed_wait
		if reaction_delta < 0:
			reaction_delta = reaction_delta * -1
		$ReactionLabel.text = str(
			"You reacted ", stepify(reaction_delta, .001), " off of the target goal"
		)
		turn_invisible(delta)


func type_of_reaction_attack(attack_type):
	type_of_attack = attack_type


func turn_invisible(delta):
	invisible_timer += delta
	if invisible_timer > time_until_invisible:
		restart_timer()
		invisible_timer = 0
		self.visible = false
		emit_signal("reaction_test_done")


# resets the reaction test by setting timers to 0 and changes the goal.
func restart_timer():
	$ReactionButton.modulate = "ffffff"
	$ReactionLabel.text = "React"
	timer = 0
	set_target_time()
	type_of_attack = 0


func start_timer():
	reaction_delta = 0
	self.visible = true
	is_running = true


func _on_ReactionButton_pressed():
	is_running = false
