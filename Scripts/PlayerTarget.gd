extends Node2D


signal target_destroyed

export var scale_size = 2

var move_speed_x: float
var move_speed_y: float

var rng := RandomNumberGenerator.new()


var screen_max_x = 1024
var screen_min_x = 0

var screen_max_y = 600
var screen_min_y = 0


# TODO maybe add a velocity here to make them move in a random dirrection
# or have them have custom sizes
func _ready() -> void:
	self.scale.x = scale_size
	self.scale.y = scale_size
	rng.randomize()
	move_speed_x = rng.randf_range(-4, 4)
	move_speed_y = rng.randf_range(-4, 4)


func _process(delta) -> void:
	
	position += Vector2(move_speed_x, move_speed_y)
	
	position.x = wrapf(position.x, screen_min_x, screen_max_x)
	position.y = wrapf(position.y, screen_min_y, screen_max_y)


func _on_TargetButton_pressed() -> void:
	emit_signal("target_destroyed")
	self.queue_free()
