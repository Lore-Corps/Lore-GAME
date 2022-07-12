extends Node2D



func _ready():
	pass # Replace with function body.



func _on_TargetButton_pressed():
	get_parent().get_node("TargetContainer")
	self.queue_free()
