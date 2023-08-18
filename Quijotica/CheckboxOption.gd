extends HBoxContainer

var id : String

func setup(identifier : String, name : String, checked : bool = false):
	id = identifier
	%CheckBox.text = name
	%CheckBox.button_pressed = checked
	%CheckBox.button_group = load("res://book_button_group.tres")

func get_button_group() -> ButtonGroup:
	return %CheckBox.button_group
