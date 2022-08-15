extends Node

signal reaction_test_done

var countdown_timer: float
var click_timestamp: float
var goal_timestamp: float
var timestamp_delta: float

var reaction_alert_color: String = "ff0000"

var is_running: bool = false
var has_finished_running: bool = false

var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	countdown_timer = rng.randf_range(1, 5)
	self.visible = false


func _physics_process(delta) -> void:
	if is_running:
		countdown_timer -= delta

		if countdown_timer <= 0:
			$ReactionButton.modulate = reaction_alert_color


func start(seconds_after_zero: float = 0) -> void:
	countdown_timer = rng.randf_range(1, 5)
	goal_timestamp = seconds_after_zero
	$ReactionLabel.text = str("React ", goal_timestamp, " seconds after color changes")
	is_running = true
	has_finished_running = false
	self.visible = true


func stop() -> void:
	is_running = false
	has_finished_running = true
	click_timestamp = countdown_timer

	# If player clicks too soon, return -1 as the delta
	if countdown_timer > 0:
		timestamp_delta = -1
		$ReactionLabel.text = str("You reacted too soon!")
	else:
		timestamp_delta = abs(click_timestamp + goal_timestamp)
		$ReactionLabel.text = str(
			"You reacted ", stepify(timestamp_delta, .001), " off of the target goal"
		)

	print(timestamp_delta)

	yield(get_tree().create_timer(2.0), "timeout")

	$ReactionButton.modulate = "ffffff"
	self.visible = false

	emit_signal("reaction_test_done")


func _on_ReactionButton_pressed():
	stop()
