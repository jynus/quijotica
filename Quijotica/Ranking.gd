extends Node2D

var line_template : PackedScene = preload("res://ranking_line.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func print_user_ranking(user : Dictionary, location: Node):
	var line = line_template.instantiate()
	line.set_values(user["user"], user["value"])
	location.add_child(line)

func update_ranking():
	for node in %TopWords.get_children():
		if node is HBoxContainer:
			node.queue_free()
	for user in Stats.get_top_users_by_words():
		print_user_ranking(user, %TopWords)

func _on_visibility_changed():
	if visible:
		update_ranking()

func _on_back_button_pressed():
	hide()
