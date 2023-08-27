extends Node2D

var submit_url : String = "https://jynus.com/quijotica/send.php"
var rankings_url : String = "https://jynus.com/quijotica/"

var line_template : PackedScene = preload("res://ranking_line.tscn")
var closed_icon : Texture2D = preload("res://assets/closed_dot.png")
var open_icon : Texture2D = preload("res://assets/open_dot.png")

var was_manual_upload : bool = false

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

func _on_share_button_pressed():
	%ShareButton.disabled = true
	was_manual_upload = true
	upload_data()

func upload_data():
	var http_dict = Stats.get_global_status("dictionary")
	http_dict["streamer"] = $"../Gift".username
	http_dict["book"] = Config.current_book

	var headers = [
		"Content-Type: application/json",
		"User-Agent: Quijotica/Godot4 (jynus.com)"
	]
	var http_body = JSON.stringify(http_dict)
	print_debug(http_body)
	%HTTPRequest.request(submit_url, headers, HTTPClient.METHOD_POST, http_body)

func _on_http_request_request_completed(result, response_code, headers, body):
	%ShareButton.disabled = false
	print_debug(response_code)
	if was_manual_upload:
		was_manual_upload = false
		if response_code == 200:
			OS.shell_open(rankings_url)
		else:
			$FaileduploadDialog.show()
