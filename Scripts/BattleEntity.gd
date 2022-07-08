extends Node

class_name BattleEntity


var char_name: String 

# stats
var max_health: int = 100
var curr_health: int = 100
var strength: int = 10
var intelligence: int = 10 
var agility: int = 10

# flags
var is_alive: bool = true
var my_turn: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Returns attack power as a Int. Right now attack is just strength but in the
# Future it will change to also include weapons and maybe mroe stats. 
func attack() -> int:
	return(strength)


func heal():
	curr_health += intelligence
	if curr_health > max_health:
		curr_health = max_health
	update_entity_label()



func random_sprite_color(color):
	$Sprite.modulate = color

func random_label_color(color):
	$PlayerInfoLabel.modulate = color

# Call this with a number to take damage. 
# It sets a death flag when HP is at or below 0
func take_damage(damage):
	curr_health -= damage
	update_entity_label()
	if curr_health <= 0:
		is_alive = false
		print("I am dead")
		kill()

func reset():
	print("current health", curr_health)
	curr_health = max_health
	is_alive = true
	$Sprite.visible = true
	update_entity_label()

func kill():
	$Sprite.visible = false




func update_entity_label(): 
	$PlayerInfoLabel.text = str(char_name, "\nStats:\n", "Health: ", 
		curr_health, "\nStrength: ", strength, "\nIntelligence: ", intelligence, 
		"\nAgility: ", agility)


