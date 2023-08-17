extends Node

var current_book : String = "don_quixote"
var accessible_font : bool = false

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
