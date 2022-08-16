extends BattleEntity


func _init() -> void:
	alignment = "good"
	#strength = 100


func _ready() -> void:
	char_name = "Zag the Protag"
	strength = 9
	print("Here I am ", char_name, "!")
	update_entity_label()

# TODO FIX FOR HAITHAR
func _on_PlayerInfoLabel_mouse_entered():
	$PlayerInfoLabel.text = "I'm a secret member of the LGBTFGC.... SHHHHHHHHH"


func _on_PlayerInfoLabel_mouse_exited():
	update_entity_label()
