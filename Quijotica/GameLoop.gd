extends Node2D

# text stuff
var text : PackedStringArray = PackedStringArray()
var line : String
var line_count : int = 0
var word : String
var word_count : int = 0
var total_words : int
var regex : RegEx = RegEx.new()

signal correct_word


func format_integer(number: int, thousands_separator: String = " ") -> String:
	var formatted_number: String = str(number)
	var i : int = formatted_number.length() - 3
	while i > 0:
		formatted_number = formatted_number.insert(i, thousands_separator)
		i = i - 3
	return formatted_number

# Called when the node enters the scene tree for the first time.
func do_text_stuff():
	var text_file = FileAccess.open("res://texts/don_quixote.txt",FileAccess.READ)
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
	word = text[0]
	%PreviousWord.text = ""
	for current_word in text:
		%Counter.text = format_integer(word_count) + " de " + format_integer(total_words)
		if word_count > 0:
			%PreviousWord.text = text[word_count - 1]
		word = text[word_count]
		%Word.text = word
		if word_count < total_words:
			%NextWord.text = text[word_count + 1]
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


func _on_gift_chat_message(sender_data, message):
	if message == word:
		correct_word.emit()
		%User.text = sender_data.tags["display-name"]
