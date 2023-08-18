extends Node2D

var line_template : PackedScene = preload("res://ranking_line.tscn")
var closed_icon : Texture2D = preload("res://assets/closed_dot.png")
var open_icon : Texture2D = preload("res://assets/open_dot.png")
@onready var rankings: Array[Dictionary] = [
	{"node": %TopWords, "function": Stats.get_top_users_by_words},
	{"node": %Faster, "function": Stats.get_top_users_by_speed},
	{"node": %LeastErrors, "function": Stats.get_top_users_by_accuracy},
	{"node": %MostErrors, "function": Stats.get_top_users_by_errors},
	{"node": %GlobalRankingContainer, "function": Stats.get_global_status}
]
@onready var buttons: Array[Button] = [
	%Page1Button,
	%Page2Button,
	%Page3Button,
	%Page4Button,
	%Page5Button
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		hide()

func print_user_ranking(user : Dictionary, location: Node):
	var line = line_template.instantiate()
	if location == %GlobalRankingContainer:
		line.set_line(user["user"], user["value"])
	else:
		line.set_values(user["user"], user["value"])
	location.add_child(line)

func update_ranking():
	for ranking in rankings:
		for node in ranking.node.get_children():
			if node is HBoxContainer:
				node.queue_free()
		for user in ranking["function"].call():
			print_user_ranking(user, ranking.node)

func _on_visibility_changed():
	if visible:
		update_ranking()

func all_icons_enabled_and_closed():
	for button in buttons:
		button.icon = closed_icon
		button.disabled = false


func go_to_page(page_index):
	create_tween().tween_property(%RankingWindows, "position:x", -800 * page_index, 0.3)
	all_icons_enabled_and_closed()
	buttons[page_index].icon = open_icon
	buttons[page_index].disabled = true

func _on_page_1_button_pressed():
	go_to_page(0)

func _on_page_2_button_pressed():
	go_to_page(1)

func _on_page_3_button_pressed():
	go_to_page(2)

func _on_page_4_button_pressed():
	go_to_page(3)

func _on_page_5_button_pressed():
	go_to_page(4)
