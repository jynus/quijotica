extends Node2D

# text stuff
var text : PackedStringArray = PackedStringArray()
var word : String
var simplified_word : String
var previous_word : String
var next_word : String
var large_window : bool = true

var correct_word_timestamp : float = 0.0
var regex : RegEx = RegEx.new()
var text_download_url : String = "https://raw.githubusercontent.com/jynus/quijotica/main/texts/"

@onready var h_box_container = $HBoxContainer
@onready var animation_player = $AnimationPlayer
@onready var stream_player = $AudioStreamPlayer

@onready var gift = %Gift

const SMALL_WINDOW_SIZE : int = 400
var letter_simplifications : Dictionary = {
	"á": "a",
	"à": "a",
	"ä": "a",
	"é": "e",
	"è": "e",
	"ë": "e",
	"í": "i",
	"ì": "i",
	"ï": "i",
	"ó": "o",
	"ò": "o",
	"ö": "o",
	"ú": "u",
	"ù": "u",
	"ü": "u",
	"ñ": "n",
	"ç": "c"
}

signal correct_word
signal old_word
signal early_word
signal misspelled_word


func format_integer(number: int, thousands_separator: String = " ") -> String:
	var formatted_number: String = str(number)
	var i : int = formatted_number.length() - 3
	while i > 0:
		formatted_number = formatted_number.insert(i, thousands_separator)
		i = i - 3
	return formatted_number


func download(link, path):
	var http = $HTTPRequest
	http.connect("request_completed", _http_request_completed)

	http.set_download_file(path)
	var request = http.request(link)
	if request != OK:
		push_error("Http request error")
	await http.request_completed

func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")

func update_state():
	if Stats.word_count > Stats.total_words or Stats.word_count < 0:
		Stats.word_count = 0  # error, start from 0

	word = text[Stats.word_count] if Stats.word_count >= 0 and Stats.word_count < Stats.total_words else ""
	simplified_word = simplify_word(word)
	previous_word = text[Stats.word_count - 1] if Stats.word_count >= 1 else ""
	next_word = text[Stats.word_count + 1] if Stats.word_count < Stats.total_words - 1 else ""

	%Word.text = word
	%Counter.text = format_integer(Stats.word_count) + " de " + format_integer(Stats.total_words)
	%PreviousWord.text = ""
	%NextWord.text = ""

	if Stats.word_count > 0:
		for i in range(Stats.word_count - 1, max(-1, Stats.word_count - 4), -1):
			%PreviousWord.text = text[i] + " " + %PreviousWord.text
	if Stats.word_count < Stats.total_words:
		for i in range(Stats.word_count + 1, min(Stats.total_words, Stats.word_count + 4)):
			%NextWord.text += text[i] + " "

	if len(word) > 3:
		%Strike.size.x = 571
		%Strike.position.x = 151
	else:
		%Strike.size.x = 287
		%Strike.position.x = 279

func load_text():
	if not FileAccess.file_exists("user://" + Config.current_book + ".txt"):
		print("Downloading book " + Config.current_book + "...")
		await download(text_download_url + Config.current_book + ".txt", "user://" + Config.current_book + ".txt")

	var text_file = FileAccess.open("user://" + Config.current_book + ".txt" , FileAccess.READ)
	if Config.current_book in ["numerica", "pi"]:
		regex.compile("[0-9]+")
	else:
		regex.compile("\\p{L}+")

	var word_counter : int = 0
	var line_counter : int = 0
	var line : String
	var current_word : String
	while not text_file.eof_reached():
		line = text_file.get_line()
		line_counter += 1
		for result in regex.search_all(line):
			current_word = result.get_string()
			word_counter += 1
			text.append(current_word)
	Stats.total_words = word_counter
	print("Total lines: ", line_counter)
	print("Total words: ", word_counter)
	text_file.close()

# Called when the node enters the scene tree for the first time.
func quijotica_loop():
	while true:
		if Stats.word_count >= Stats.total_words:
			break

		update_state()

		await correct_word
		Stats.word_count += 1
		
		if Stats.word_count % 100 == 0:
			Stats.save_state(Config.current_book)
		if large_window:
			animation_player.play("correct_word_2")
			await animation_player.animation_finished
	Stats.save_state(Config.current_book)
	%Credits.win()

# Called when the node enters the scene tree for the first time.
func _ready():
	%Overlay.show()
	get_tree().set_auto_accept_quit(false)
	stream_player.play()
	stream_player.stream_paused = true
	get_tree().root.connect("size_changed", _on_viewport_size_changed)
	load_text()
	Stats.load_state(Config.current_book)


func _on_viewport_size_changed():
	# Do whatever you need to do when the window changes!
	print ("Viewport size changed: ", get_viewport().size)
	if large_window and get_viewport().size.x < SMALL_WINDOW_SIZE or get_viewport().size.x < SMALL_WINDOW_SIZE:
		large_window = false
		%Overlay.hide()
		%PreviousWord.hide()
		%NextWord.hide()
		$HBoxContainer/MarginContainer.hide()
		$HBoxContainer/MarginContainer2.hide()
		%Word.custom_minimum_size.x = 800
		%Word.label_settings.font_size = 320
		%Counter.hide()
		%User.hide()
		%WaterMark.hide()
	elif not large_window and get_viewport().size.x >= SMALL_WINDOW_SIZE and get_viewport().size.x >= SMALL_WINDOW_SIZE:
		large_window = true
		%Overlay.show()
		%PreviousWord.show()
		%NextWord.show()
		$HBoxContainer/MarginContainer.show()
		$HBoxContainer/MarginContainer2.show()
		%Word.custom_minimum_size.x = 0
		%Word.label_settings.font_size = 280
		%Counter.show()
		%User.show()
		%WaterMark.show()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_exit()

func _on_start_menu_connect():
	gift.setup()


func _on_gift_joined_chatroom():
	%start_menu.hide()
	correct_word_timestamp = Time.get_unix_time_from_system()
	quijotica_loop()
	%Gift.connect("chat_message", _on_gift_chat_message)

func simplify_word(word : String) -> String:
	var simplified_word : String = ""
	for letter in word.to_lower():
		simplified_word += letter_simplifications[letter] if letter in letter_simplifications else letter
	return simplified_word

func add_mistake(user):
	if not user in Stats.users:
		Stats.users[user] = {"words": 0, "time": 0, "errors": 0}
	Stats.users[user] = {
		"words": Stats.users[user]["words"],
		"time": Stats.users[user]["time"],
		"errors": Stats.users[user]["errors"] + 1
	}

func _on_gift_chat_message(sender_data, message):
	var user : String = sender_data.tags["display-name"]
	if message == word:
		var current_timestamp : float = Time.get_unix_time_from_system()
		correct_word.emit()
		if not user in Stats.users:
			Stats.users[user] = {"words": 0, "time": 0, "errors": 0}
		Stats.users[user] = {
			"words": Stats.users[user]["words"] + 1,
			"time": Stats.users[user]["time"] + max(0.0, current_timestamp - correct_word_timestamp),
			"errors": Stats.users[user]["errors"]
		}
		correct_word_timestamp = current_timestamp
		%User.text = user
		%User.label_settings.font_color = Color(0, 0, 0)
		return
	if message == next_word:
		early_word.emit()
		%User.text = "✖ " + user
		%User.label_settings.font_color = Color(0.5, 0.5, 0.5)
		add_mistake(user)
		return
	if message == previous_word:
		# do not check beyond 10 seconds
		if Time.get_unix_time_from_system() - correct_word_timestamp > 10.0:
			return
		old_word.emit()
		%User.text = "✖ " + user
		%User.label_settings.font_color = Color(0.5, 0.5, 0.5)
		add_mistake(user)
		return
	if message == simplified_word or word.similarity(message) >= 0.5:
		misspelled_word.emit()
		%User.text = "✖ " + user
		%User.label_settings.font_color = Color(1, 0.2, 0.2)
		add_mistake(user)

func _exit():
	print("Exiting normally...")
	gift.disconnect("chat_message", _on_gift_chat_message)
	gift.leave()
	#await gift.left_chatroom
	remove_child(gift)
	# Save status
	Stats.save_state(Config.current_book)
	#await gift.tree_exited
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _on_overlay_show_stats():
	%Ranking.show()

func _on_overlay_show_settings():
	%Settings.show()

func _on_overlay_show_credits():
	%Credits.show()

func _on_overlay_show_rules():
	%Rules.show()

func start_writing_sound():
	stream_player.pitch_scale = randf_range(0.5, 1.5)
	stream_player.stream_paused = false

func stop_writing_sound():
	stream_player.stream_paused = true

func change_book(new_book: String):
	Stats.save_state(Config.current_book)
	Config.current_book = new_book
	%WaterMark.texture = load(Config.book_list[new_book]["image"])
	%Gift.disconnect("chat_message", _on_gift_chat_message)
	Stats.load_state(Config.current_book)
	text = []
	load_text()
	update_state()
	%Gift.connect("chat_message",  _on_gift_chat_message)
