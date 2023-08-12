extends Node2D

# text stuff
var text : PackedStringArray = PackedStringArray()
var line : String
var line_count : int = 0
var word : String
var simplified_word : String
var previous_word : String
var next_word : String
var word_count : int = 0
var total_words : int
var correct_word_timestamp : float = 0.0
var regex : RegEx = RegEx.new()

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

# Called when the node enters the scene tree for the first time.
func do_text_stuff():
	var text_file : FileAccess
	if FileAccess.file_exists("user://don_quixote.txt"):
		text_file = FileAccess.open("user://don_quixote.txt", FileAccess.READ)
	else:
		return

	regex.compile("\\p{L}+")

	while not text_file.eof_reached():
		line = text_file.get_line()
		line_count += 1
		for result in regex.search_all(line):
			word = result.get_string()
			word_count += 1
			text.append(word)
	total_words = word_count
	print("Total lines: ", line_count)
	print("Total words: ", word_count)
	text_file.close()

	word_count = 0
	line_count = 0
	word = text[0] if len(text) > 0 else ""
	previous_word = ""
	next_word = text[1] if len(text) > 1 else ""
	%PreviousWord.text = previous_word
	for current_word in text:
		%Counter.text = format_integer(word_count) + " de " + format_integer(total_words)
		if word_count > 0:
			previous_word = text[word_count - 1]
			%PreviousWord.text = previous_word
		word = text[word_count]
		simplified_word = simplify_word(word)
		%Word.text = word
		if word_count < total_words:
			next_word = text[word_count + 1]
			%NextWord.text = next_word
		else:
			break  # you win!
		await correct_word
		word_count += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	do_text_stuff()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_start_menu_connect():
	%Gift.setup()


func _on_gift_twitch_connected():
	%start_menu.hide()

func simplify_word(word : String) -> String:
	var simplified_word : String = ""
	for letter in word.to_lower():
		simplified_word += letter_simplifications[letter] if letter in letter_simplifications else letter
	return simplified_word


func _on_gift_chat_message(sender_data, message):
	if message == word:
		correct_word.emit()
		correct_word_timestamp = Time.get_unix_time_from_system()
		%User.text = sender_data.tags["display-name"]
		%User.label_settings.font_color = Color(0, 0, 0)
		return
	if message == next_word:
		early_word.emit()
		%User.text = "✖ " + sender_data.tags["display-name"]
		%User.label_settings.font_color = Color(0.5, 0.5, 0.5)
		return
	if message == previous_word:
		# do not check beyond 10 seconds
		if Time.get_unix_time_from_system() - correct_word_timestamp > 10.0:
			return
		old_word.emit()
		%User.text = "✖ " + sender_data.tags["display-name"]
		%User.label_settings.font_color = Color(0.5, 0.5, 0.5)
		return
	if message == simplified_word or word.similarity(message) >= 0.5:
		misspelled_word.emit()
		%User.text = "✖ " + sender_data.tags["display-name"]
		%User.label_settings.font_color = Color(1, 0.2, 0.2)
