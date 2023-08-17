extends Node2D

var line_template : PackedScene = preload("res://ranking_line.tscn")
@onready var location = %Credits
@onready var scroll = %ScrollCredits

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_data()

func refresh_data():
	scroll.get_v_scroll_bar().value = 0
	return update_users()

func update_users() -> int:
	var users: Array = Stats.get_all_users_in_order_of_appearance()
	for node in location.get_children():
		if node is HBoxContainer:
			node.queue_free()
	for user in users:
		var line = line_template.instantiate()
		line.set_values(user["user"], user["value"])
		location.add_child(line)
	return len(users)

func _on_visibility_changed():
	if visible:
		refresh_data()

func win():
	var num_users = refresh_data()
	show()
	%VictoryMusic.play()
	%CreditsTitle.label_settings.font_size = 50
	%CreditsTitle.text = "Confía en el tiempo, que suele dar dulces salidas a muchas amargas dificultades"
	var scrollBar : VScrollBar = scroll.get_v_scroll_bar()
	var max_value : int = scrollBar.max_value
	create_tween().tween_property(scrollBar, "value", max_value + 200, max_value / 40)
