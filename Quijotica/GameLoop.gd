extends Node2D

# text stuff
var text : PackedStringArray = PackedStringArray()
var word : String
var simplified_word : String
var previous_word : String
var next_word : String
var large_window : bool = true
var ignore_chat : bool = false

var correct_word_timestamp : float = 0.0
var regex : RegEx = RegEx.new()
var text_download_url : String = "https://raw.githubusercontent.com/jynus/quijotica/main/texts/"
var connected : bool = false

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

enum ban_reason {SPELLING, TOO_LATE, TOO_SOON, WRONG_COMMAND}

var banned_users : Dictionary = {}

signal correct_word
signal old_word
signal early_word
signal misspelled_word
signal wrong_command
signal text_loaded

func format_integer(number: int, thousands_separator: String = " ") -> String:
	var formatted_number: String = str(number)
	var i : int = formatted_number.length() - 3
	while i > 0:
		formatted_number = formatted_number.insert(i, thousands_separator)
		i = i - 3
	return formatted_number


func download(link, path):
	var http = $HTTPRequest
	if not http.is_connected("request_completed", _http_request_completed):
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
		%NextWord.text = " " + %NextWord.text 

	%Strike.size.x = len(%Word.text) * 75
	%Strike.global_position.x = 400 - %Strike.size.x / 2

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
	%Credits/VictoryMusic.stream = load(Config.book_list[Config.current_book].music)
	text_loaded.emit()

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
			if Config.automatic_upload:
				%Ranking.upload_data()
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
	Config.load_options()
	%Settings.update_settings()
	update_book_decoration()
	Stats.load_state(Config.current_book)
	load_text()
	await %Gift.chat_message
	quijotica_loop()

func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		%ConfirmationDialog.show()

func redraw_window():
	var font = "res://assets/coolvetica rg.otf" if Config.accessible_font else "res://assets/Don_Quixote.ttf"
	%PreviousWord.label_settings.font = load(font)
	%Word.label_settings.font = load(font)
	%NextWord.label_settings.font = load(font)

	if large_window:
		%Overlay.show()
		%PreviousWord.show()
		%NextWord.show()
		$HBoxContainer/MarginContainer.show()
		$HBoxContainer/MarginContainer2.show()
		$HBoxContainer.custom_minimum_size.x = 1600
		%Word.custom_minimum_size.x = 0
		%Word.label_settings.font_size = 120 if Config.accessible_font else 270
		%PreviousWord.label_settings.font_size = 75 if Config.accessible_font else 180
		%NextWord.label_settings.font_size = 75 if Config.accessible_font else 180
		%Counter.show()
		%User.show()
		%WaterMark.show()
		$HBoxContainer.global_position = \
			Vector2(400 - $HBoxContainer.size.x / 2, \
					120 if Config.accessible_font else 182)
	else:
		%Overlay.hide()
		%PreviousWord.hide()
		%NextWord.hide()
		$HBoxContainer/MarginContainer.hide()
		$HBoxContainer/MarginContainer2.hide()
		$HBoxContainer.global_position = Vector2(0, 150)
		$HBoxContainer.custom_minimum_size.x = 1600
		%Word.custom_minimum_size.x = 800
		%Word.label_settings.font_size = 140 if Config.accessible_font else 320
		%Counter.hide()
		%User.hide()
		%WaterMark.hide()

func _on_viewport_size_changed():
	# Do whatever you need to do when the window changes!
	print_debug("Viewport size changed: ", get_viewport().size)
	if large_window and get_viewport().size.x < SMALL_WINDOW_SIZE or get_viewport().size.x < SMALL_WINDOW_SIZE:
		print("Enabling zen mode")
		large_window = false
		redraw_window()
	elif not large_window and get_viewport().size.x >= SMALL_WINDOW_SIZE and get_viewport().size.x >= SMALL_WINDOW_SIZE:
		print("Disabling zen mode")
		large_window = true
		redraw_window()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_exit()

func _on_start_menu_connect():
	gift.setup()


func _on_gift_joined_chatroom():
	connected = true
	var username : String = %Gift.username.to_lower()
	match username:
		"isaacsanchez_art":
			%User.text = "Esperant malparits ..."
		"rothiotome":
			%User.text = "Esperando colgajos ..."
		"psuzume":
			%User.text = "Esperando muelas ..."
		"idlesir":
			%User.text = "Esperando manos sexis ..."
		"melenitasdev":
			%User.text = "Esperando TikToks ..."
		"afor_digital":
			%User.text = "Esperando formulario de contacto ..."
		"niv3k_el_pato":
			%User.text = "Esperando patitos ..."
		"papajoshhh":
			%User.text = "Esperando Silksong ..."
		"kerk1":
			%User.text = "berriketan zain ..."
		"senseidani":
			%User.text = "Esperando a Ame y Suna ..."
		"algebrodev":
			%User.text = "Esperando que cargue Unity ..."
		"catisa":
			%User.text = "Esperando release de FromSoftware ..."
		"ransilftw":
			%User.text = "Esperando a la Nintendo Direct ..."
		"sailorfu":
			%User.text = "Esperando croquetas para Shiva ..."
		"altaskur":
			%User.text = "Haciendo async/await en el chat ..."
		"carmenpilar26":
			%User.text = "Esperando release de FromSoftware ..."
		"lascosicasdejoserra":
			%User.text = "Esperando panes ..."
		"outconsumer":
			%User.text = "Esperando wokes ..."
		_:
			%User.text = "Aguardando ruines ..."

	%start_menu.hide()
	await get_tree().create_timer(2).timeout
	var command_text : String = ""
	if Config.command != "":
		command_text = " El comando es " + Config.command + " ."
	chat("Hola! 👋 Soy Quijótica. Vamos por " + str(Stats.word_count) + " de " + str(Stats.total_words) + " palabras. Comandos: !quijótica !palabras !clasificación ." + command_text)
	correct_word_timestamp = Time.get_unix_time_from_system()

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

func ban_or_ignore(user: String, reason: ban_reason):
	var timestamp : int = Time.get_unix_time_from_system()
	match reason:
		ban_reason.SPELLING:
			%User.text = "✖ " + user
			%User.label_settings.font_color = Color(1, 0.2, 0.2)
			chat("@" + user + " ❌ aprende ortografía 😡")
		ban_reason.TOO_SOON:
			%User.text = "✖ " + user
			%User.label_settings.font_color = Color(0.5, 0.5, 0.5)
			chat("@" + user + " ❌ demasiado pronto! 🧘")
		ban_reason.TOO_LATE:
			%User.text = "✖ " + user
			%User.label_settings.font_color = Color(0.5, 0.5, 0.5)
			chat("@" + user + " ❌ demasiado tarde! 🏃")
		ban_reason.WRONG_COMMAND:
			%User.text = "✖ " + user
			%User.label_settings.font_color = Color(1, 0.4, 0.4)
			chat("@" + user + " ❌ comando inválido! 🛑")

	banned_users[user.to_lower()] = timestamp + Config.ban_time

func _on_gift_chat_message(sender_data, message):
	if ignore_chat:
		return
	var user : String = sender_data.tags["display-name"]
	var timestamp : int = Time.get_unix_time_from_system()
	var command_text : String = ""
	if message == "!quijótica":
		if Config.command != "":
			command_text = " El comando es " + Config.command + " ."
		chat("Escribe la palabra que ves en pantalla. Si te equivocas no podrás escribir durante " + str(Config.ban_time) + " segundos." + command_text)
		return
	if message == "!palabras":
		var words : int = 0
		var errors : int = 0
		if user in Stats.users:
			words = Stats.users[user]["words"]
			errors = Stats.users[user]["errors"]
		chat("@" + user + " tienes " + str(words) + " palabras correctas y " + str(errors) + " errores.")
		return
	if message == "!clasificación":
		var top_users = Stats.get_top_users_by_words(3)
		if len(top_users) == 0:
			chat("No hay ningún usuario que haya escrito ninguna palabra todavía.")
			return
		var text : String = "Los usuarios con más palabras son: "
		for top_user in top_users:
			text += top_user["user"] + " (" + str(top_user["value"]) + ") "
		chat(text)
		return
	if user.to_lower() in banned_users and banned_users[user.to_lower()] > timestamp:
		return  # user is banned
	if Config.command != "":
		if message.begins_with(Config.command + " "):
			message = message.substr(len(Config.command) + 1, -1).strip_edges()
		else:
			return  # ignore words not starting with the custom command
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
		ban_or_ignore(user, ban_reason.TOO_SOON)
		add_mistake(user)
		return
	if message == previous_word:
		# do not check beyond 10 seconds
		if Time.get_unix_time_from_system() - correct_word_timestamp > 10.0:
			return
		old_word.emit()
		ban_or_ignore(user, ban_reason.TOO_LATE)
		add_mistake(user)
		return
	if message == simplified_word or word.similarity(message) >= 0.5:
		misspelled_word.emit()
		ban_or_ignore(user, ban_reason.SPELLING)
		add_mistake(user)
		return
	if Config.command != "":
		wrong_command.emit()
		ban_or_ignore(user, ban_reason.WRONG_COMMAND)
		add_mistake(user)

func _exit():
	print("Exiting normally...")
	ignore_chat = true
	if connected:
		gift.disconnect("chat_message", _on_gift_chat_message)
		gift.leave()
		connected = false
	#await gift.left_chatroom
	remove_child(gift)
	# Save status
	Stats.save_state(Config.current_book)
	Config.save_options()
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

func update_book_decoration():
	%WaterMark.texture = load(Config.book_list[Config.current_book]["image"])
	%start_menu/Background/Image.texture = load(Config.book_list[Config.current_book]["background"])
	%start_menu/Background/Title.text = Config.book_list[Config.current_book]["title"]
	%start_menu/Background/Button.text = Config.book_list[Config.current_book]["conectar"]	

func change_book(new_book: String):
	Stats.save_state(Config.current_book)
	Config.current_book = new_book
	update_book_decoration()
	ignore_chat = true
	text = []
	Stats.load_state(Config.current_book)
	load_text()

func _on_text_loaded():
	update_state()
	redraw_window()
	#quijotica_loop()
	ignore_chat = false

func _on_reset_all_data():
	print("Resetting all data...")
	ignore_chat = true
	if connected:
		if gift.is_connected("chat_message", _on_gift_chat_message):
			gift.disconnect("chat_message", _on_gift_chat_message)
		gift.leave()
		connected = false
	#await gift.left_chatroom
	remove_child(gift)
	print("About to move to trash directory: " + OS.get_user_data_dir())
	OS.move_to_trash(OS.get_user_data_dir())
	await get_tree().create_timer(0.5).timeout
	print("Launching new game instance...")
	#OS.execute(OS.get_executable_path(), OS.get_cmdline_args())
	OS.create_instance(OS.get_cmdline_args())
	print("Now quitting.")
	get_tree().quit()


func expire_bans():
	var timestamp : int = Time.get_unix_time_from_system()
	for user in banned_users.keys():
		if banned_users[user] < timestamp:
			banned_users.erase(user)
			chat("@" + user + " hola de vuelta 👋")

func chat(msg: String):
	if Config.chat_enabled:
		%Gift.chat(msg)

func _on_exit_dialog_confirmed():
	_exit()
