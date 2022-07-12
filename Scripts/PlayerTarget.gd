extends Node2D


signal target_destroyed


func _ready() -> void:
	pass



func _on_TargetButton_pressed() -> void:
	emit_signal("target_destroyed")
	self.queue_free()
