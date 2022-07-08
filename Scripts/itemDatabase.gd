extends Node

class_name ItemDatabase

class item:
	
	
	var name: String = "default"
	# Depending on how we do it, might just have unlocks so you can use it for any character
	var is_unlocked: bool
	
	# Might store them into an array
	var attributes
	
	var strength: int
	var intelligence: int
	var agility: int
	
	# Note sure what this will be yet.
	var modifiers
	
	# Basic constructer for items
	func _init(item_name: String, unlocked: bool, stre: int, inte: int, agil: int):
		name = item_name
		is_unlocked = unlocked
		strength = stre
		intelligence = inte
		agility = agil
		

# Where we will store all the items.
var items: Dictionary = {
	"Sword": item.new("Sword", true, 5, 4, 3)
}
