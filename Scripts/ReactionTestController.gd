extends Node

signal reaction_test_done

var timer: float
#Time when timer stopped. Attack types edit this when sending it to the battleController
var reaction_delta: float

var is_running: bool = false
var reaction_alert_time: float

# Show "CRITICAL FAILURE!" on the ui to indicate button will vanish soon
# this is if the player waits too long without hitting the button
var critical_failure_time: float

var time_until_invisible: int = 1

# 0 is no attack. 1 is attack. 2 is delayed attack
var type_of_attack: int

var random_reaction_alert_time = RandomNumberGenerator.new()

var invisible_timer: float

var target_time_to_react: float


func _ready():
	set_reaction_alert_time()
	self.visible = false


func set_reaction_alert_time():
	random_reaction_alert_time.randomize()
	reaction_alert_time = random_reaction_alert_time.randf_range(0.4, 5)
	critical_failure_time = reaction_alert_time + 2.7
	#This was just for testing
	#reaction_alert_time = 2


func _physics_process(delta):
	if is_running:
		timer += delta
	if timer >= reaction_alert_time:
		$ReactionButton.modulate = "bb4444"
	# Checks the attack type then waits for the player to react.
	# Once player reacts it deals damage and then starts the cool down to turn
	# Invisible. Timer gets reset once it turns invisible.
	if type_of_attack == 1:
		$ReactionLabel.text = str("React after ", target_time_to_react, " seconds")
		if not is_running:
			logic_for_default_attack()
			turn_invisible(delta)




func logic_for_default_attack():
	print(target_time_to_react)
	
	reaction_delta = timer - reaction_alert_time
	reaction_delta += target_time_to_react

	$ReactionLabel.text = str(
		"You reacted ", stepify(reaction_delta, .001), " off of the target goal"
	)

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
	set_reaction_alert_time()
	type_of_attack = 0

# Has a default argument 0. 
func start_timer(_target_time_to_react = 0):
	target_time_to_react = _target_time_to_react
	reaction_delta = 0
	self.visible = true
	is_running = true


func _on_ReactionButton_pressed():
	is_running = false
