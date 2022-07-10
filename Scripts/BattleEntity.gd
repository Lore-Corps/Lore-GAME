class_name BattleEntity
extends Node

var char_name: String
# Alignemtn is used to sort BattleEntity's team. 
# Enemys will be evil and players will be good
# Default/Neutral has no use.... for now.
var alignment: String = "neutral"

# stats
# Stength for now just deals damage.
# Intelligence is for healing. Currently only Enemy Entity have a heal
# Agility is for turn order. 
var max_health: int = 100
var current_health: int = 100
var strength: int = 10
var intelligence: int = 10
var agility: int = 10

# flags
var is_alive: bool = true
var is_active: bool = false


func _ready():
	pass  # Replace with function body.


# Returns attack power as a Int. Right now attack is just strength but in the
# Future it will change to also include weapons and maybe mroe stats.
func get_strength() -> int:
	return strength


func heal()-> void:
	current_health += intelligence
	if current_health > max_health:
		current_health = max_health
	change_color_on_heal()
	update_entity_label()

func change_color_on_heal() -> void:
	$CharacterSprite.modulate = "e8fe22"
	yield(get_tree().create_timer(0.2), "timeout")
	$CharacterSprite.modulate = "ffffff"


# Call this with a number to take damage.
# It sets a death flag when HP is at or below 0
func take_damage(damage)-> void:
	current_health -= damage
	if damage > 0:
		change_color_on_take_damage()
	else: 
		change_color_on_heal()
	update_entity_label()
	if current_health <= 0:
		is_alive = false
		print("I am dead")
		kill()

# Makes the CharacterSprite flash red when taking damage
func change_color_on_take_damage() -> void:
	$CharacterSprite.modulate = "cd2626"
	yield(get_tree().create_timer(0.2), "timeout")
	$CharacterSprite.modulate = "ffffff"

func activate() -> void:
	is_active = true
	$ActiveSprite.visible = true


func deactivate() -> void:
	is_active = false
	$ActiveSprite.visible = false


func reset()-> void:
	print("current health", current_health)
	current_health = max_health
	is_alive = true
	$CharacterSprite.visible = true
	update_entity_label()


func kill()-> void:
	$CharacterSprite.visible = false


func update_entity_label()-> void:
	$PlayerInfoLabel.text = str(
		char_name,
		"\nStats:",
		"\nHealth: ",
		current_health,
		"\nStrength: ",
		strength,
		"\nIntelligence: ",
		intelligence,
		"\nAgility: ",
		agility
	)
