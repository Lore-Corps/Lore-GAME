extends BattleEntity

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	randomize_stats()
	char_name = "Brad the Madlad"
	print("Here I am ", char_name, "!")
	update_entity_label()


func reset():
	.reset()
	randomize_stats()

func randomize_stats():
	rng.randomize()
	agility = rng.randi_range(5, 20)
	intelligence = rng.randi_range(5, 20)
	strength = rng.randi_range(5, 20)
	max_health = rng.randi_range(50, 200)
	curr_health = max_health
