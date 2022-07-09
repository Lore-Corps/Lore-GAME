extends Node

signal reaction_test_done

var timer: float
#Time when timer stopped. Attack types edit this when sending it to the battleController
var timer_stopped: float

var is_running: bool = false
var target_time: float

# Show "CRITICAL FAILURE!" on the ui to indicate button will vanish soon
# this is if the player waits too long without hitting the button
var critical_failure_time: float

var time_until_invisible: int = 2

# 0 is no attack. 1 is attack. 2 is delayed attack
var type_of_attack: int
var delayed_wait: int = 2

var random_target_time = RandomNumberGenerator.new()

var invisibile_timer: float


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
			$ReactionTestButtonLabel.text = str("React after ", delayed_wait, " seconds")
	if timer >= target_time:
		$ReactionButton.modulate = "bb4444"
	if !is_running && timer > 0.0001 && type_of_attack == 1:
		timer_stopped = (timer - target_time) * .75
		$ReactionTestButtonLabel.text = str("You reacted in ", stepify(timer_stopped, .001))
		turn_invisible(delta)
	if !is_running && timer > 0.0001 && type_of_attack == 2:
		timer_stopped = timer - target_time - delayed_wait
		if timer_stopped < 0:
			timer_stopped = timer_stopped * -1
		$ReactionTestButtonLabel.text = str(
			"You reacted ", stepify(timer_stopped, .001), " off of the target goal"
		)
		turn_invisible(delta)


func type_of_reaction_attack(attack_type):
	type_of_attack = attack_type


func turn_invisible(delta):
	invisibile_timer += delta
	if invisibile_timer > time_until_invisible:
		restart_timer()
		invisibile_timer = 0
		self.visible = false
		emit_signal("reaction_test_done")


# resets the reaction test by setting timers to 0 and changes the goal.
func restart_timer():
	$ReactionButton.modulate = "ffffff"
	$ReactionTestButtonLabel.text = "React"
	timer = 0
	set_target_time()
	timer_stopped = 0
	type_of_attack = 0
	print("We got to restart timer")


func start_timer():
	self.visible = true
	is_running = true


func _on_ReactionButton_pressed():
	is_running = false