extends Area2D

var rng := RandomNumberGenerator.new()
export var TIMER_MAX = 1
var timer: float = TIMER_MAX

var active: bool = false

var random_chance: int

onready var battle_scene = get_parent().get_node("Battle")

onready var overworld_music = get_parent().get_node("OverworldMusic")


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


func _process(delta):
	if not battle_scene.is_active:
		if overworld_music.playing == false:
			overworld_music.playing = true
		print(active)
		print(timer)
		if active:
			timer -= delta
			if timer <= 0:
				random_chance = rng.randi_range(0, 2)
				print("r, ", random_chance)
				timer = TIMER_MAX
				if random_chance == 0:
					overworld_music.playing = false
					print("eeeeeeeeeee")
					battle_scene.start_scene()
	else:
		timer = 5



func _on_FightTrigger_body_entered(body: Node):
	if body.is_in_group("player"):
		timer = TIMER_MAX
		active = true


func _on_FightTrigger_body_exited(body: Node):
	if body.is_in_group("player"):
		active = false
