extends KinematicBody2D

var movement_speed: int
var velocity = Vector2(0, 0)

func _ready():
	movement_speed = 100

func _physics_process(delta):
	movement()
	velocity = move_and_slide(velocity)
	


func movement() -> void:
	velocity = Vector2()
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x = 1
	velocity = velocity.normalized() * movement_speed
