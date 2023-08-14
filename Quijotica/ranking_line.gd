extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_values(user, value):
	#var length : int = int(50 - 2 * (len(user) + len(str(value)) + 4))
	$User.text = user
	#+ " ." + ".".repeat(length) + " " +
	$Value.text = str(value)

func set_line(property, value):
	$MarginContainer.custom_minimum_size.x = 10
	$User.text = property + ": "
	$User.custom_minimum_size.x = 0
	$Dots.text = ""
	$Dots.custom_minimum_size.x = 0
	$Value.text = value
	$Value.custom_minimum_size.x = 0
	$MarginContainer2.custom_minimum_size.x = 0
