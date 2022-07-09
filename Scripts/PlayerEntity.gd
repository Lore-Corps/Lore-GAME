extends BattleEntity


func _init() -> void:
	alignment = "good"
	strength = 100


func _ready() -> void:
	char_name = "Zag the Protag"
	#strength = 5
	print("Here I am ", char_name, "!")
	update_entity_label()
