extends Node

class_name BattleEntity

var char_name: String
var alignment: String = "neutral"

# stats
var max_health: int = 100
var current_health: int = 100
var strength: int = 10
var intelligence: int = 10
var agility: int = 10

# flags
var is_alive: bool = true
var is_active: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Returns attack power as a Int. Right now attack is just strength but in the
# Future it will change to also include weapons and maybe mroe stats.
func get_strength() -> int:
	return strength


func heal():
	current_health += intelligence
	if current_health > max_health:
		current_health = max_health
	update_entity_label()


# Call this with a number to take damage.
# It sets a death flag when HP is at or below 0
func take_damage(damage):
	current_health -= damage
	update_entity_label()
	if current_health <= 0:
		is_alive = false
		print("I am dead")
		kill()


func activate() -> void:
	is_active = true
	$ActiveSprite.visible = true


func deactivate() -> void:
	is_active = false
	$ActiveSprite.visible = false


func reset():
	print("current health", current_health)
	current_health = max_health
	is_alive = true
	$CharacterSprite.visible = true
	update_entity_label()


func kill():
	$CharacterSprite.visible = false


func update_entity_label():
	$PlayerInfoLabel.text = str(
		char_name,
		"\nStats:\n",
		"Health: ",
		current_health,
		"\nStrength: ",
		strength,
		"\nIntelligence: ",
		intelligence,
		"\nAgility: ",
		agility
	)
