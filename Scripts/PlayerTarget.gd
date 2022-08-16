extends Node2D


signal target_destroyed

export var scale_size = 1

var move_speed_x: float
var move_speed_y: float

var rng := RandomNumberGenerator.new()


export var screen_max_x = 1024
export var screen_min_x = 0

export var screen_max_y = 600
export var screen_min_y = 0

var only_ran: float

# TODO maybe add a velocity here to make them move in a random dirrection
# or have them have custom sizes
func _ready() -> void:
	rng.randomize()
	only_ran = rng.randf_range(-4, 4)
	self.scale.x = only_ran
	self.scale.y = only_ran
	move_speed_x = only_ran
	move_speed_y = only_ran
	self.modulate = Color(rng.randf_range(0, 1),rng.randf_range(0, 1),rng.randf_range(0, 1))


func _process(delta) -> void:
	
	position += Vector2(move_speed_x, move_speed_y)

	position.x = wrapf(position.x, screen_min_x, screen_max_x)
	position.y = wrapf(position.y, screen_min_y, screen_max_y)


func _on_TargetButton_pressed() -> void:
	emit_signal("target_destroyed")
	self.queue_free()
