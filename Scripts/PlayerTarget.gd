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

var random_speed: float
var random_scale: float

# TODO maybe add a velocity here to make them move in a random dirrection
# or have them have custom sizes
func _ready() -> void:
	rng.randomize()
	random_speed = rng.randf_range(-400, 400)
	random_scale = rng.randf_range(1, 2)
	self.scale.x = random_scale 
	self.scale.y = random_scale 
	move_speed_x = random_speed
	move_speed_y = random_speed
	self.modulate = Color(rng.randf_range(0, 1),rng.randf_range(0, 1),rng.randf_range(0, 1))


func _process(delta) -> void:
	
	position += Vector2(move_speed_x, move_speed_y) * delta
	
	position.x = wrapf(position.x, screen_min_x, screen_max_x)
	position.y = wrapf(position.y, screen_min_y, screen_max_y)


func _on_PlayerTarget_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		emit_signal("target_destroyed")
		self.queue_free()
