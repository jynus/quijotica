extends Node

var current_book : String = "don_quixote"
var accessible_font : bool = false
var volume : float = 50

var path : String = "user://quijotica.config"

var book_list : Dictionary = {
	"don_quixote": {
		"name": "Don Quijote",
		"image": "res://assets/cervantes.png",
		"music": "res://assets/Victory.mp3",
		"background": "res://assets/Don_Quixote_fighting_windmills.png",
		"title": "Quijótica",
		"conectar": "Enclavijar"
	},
	"biblia_1909": {
		"name": "La Biblia",
		"image":"res://assets/fsm.png",
		"music": "res://assets/Victory.mp3",
		"background": "res://assets/Don_Quixote_fighting_windmills.png",
		"title": "Quijótica",
		"conectar": "Rezar"
	},
	"frankenstein_ingles": {
		"name": "Frankenstein",
		"image":"res://assets/Frankenstein.png",
		"music": "res://assets/Victory.mp3",
		"background": "res://assets/Don_Quixote_fighting_windmills.png",
		"title": "Frankenstérica",
		"conectar": "Dar vida"
	},
	"manifiesto_comunista": {
		"name": "El Manifiesto Comunista",
		"image":"res://assets/Communist_heart.png",
		"music": "res://assets/USSR_Anthem_-_1977.ogg",
		"background": "res://assets/Karl_Marx_001.png",
		"title": "Marxótica",
		"conectar": "Quemar iglesias"
	},
	"numerica": {
		"name": "Numerica",
		"image":"res://assets/numerica.png",
		"music": "res://assets/Victory.mp3",
		"background": "res://assets/Don_Quixote_fighting_windmills.png",
		"title": "Numérica",
		"conectar": "ConnectTo Twitch"
	},
	"pi": {
		"name": "Pi",
		"image":"res://assets/pi.png",
		"music": "res://assets/Victory.mp3",
		"background": "res://assets/Don_Quixote_fighting_windmills.png",
		"title": "Piérica",
		"conectar": "Calcular"
	}
}

signal config_loaded

func load_options():
	if not FileAccess.file_exists(path):
		return  # use the above defaults
	var options_file = FileAccess.open(path, FileAccess.READ)
	var json_string = options_file.get_as_text()
	options_file.close()
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	var options_dict = json.get_data()
	
	current_book = options_dict.current_book if "current_book" in options_dict else "don_quixote"
	accessible_font = options_dict.accessible_font if "accessible_font" in options_dict else false
	volume = options_dict.volume if "volume" in options_dict else 50

	print("Loaded game options from file.")

func save_options():
	var save_dict = {
		"current_book": current_book,
		"accessible_font": accessible_font,
		"volume": volume
	}
	var options_file = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	options_file.store_line(json_string)
	options_file.close()

	print("Saved game options to disk.")
