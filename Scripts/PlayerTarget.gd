extends Node2D


signal target_destroyed

# TODO maybe add a velocity here to make them move in a random dirrection
# or have them have custom sizes
func _ready() -> void:
	pass


func _on_TargetButton_pressed() -> void:
	emit_signal("target_destroyed")
	self.queue_free()
