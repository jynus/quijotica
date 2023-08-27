extends Node2D

signal redraw_window
signal book_changed
signal reset_all_data

var checkbox : PackedScene = preload("res://checkbox_option.tscn")
@onready var master_index : int = AudioServer.get_bus_index("Master")

# Called when the node enters the scene tree for the first time.
func _ready():
	%AudioStreamPlayer.play()
	%AudioStreamPlayer.stream_paused = true
	update_settings()

func update_settings():
	for node in %BookOptions.get_children():
		node.queue_free()
	var cb : Node
	for book in Config.book_list:
		cb = checkbox.instantiate()
		var option_name : String = " " + Config.book_list[book].name
		cb.setup(book, option_name, book == Config.current_book)
		%BookOptions.add_child(cb)
	if len(Config.book_list) > 0 and not cb.get_button_group().is_connected("pressed", book_pressed):
		cb.get_button_group().connect("pressed", book_pressed)
	%VolumeSlider.value = Config.volume
	%AccessibleFontCheckBox.button_pressed = Config.accessible_font
	if Config.accessible_font:
		%AccessibleFontCheckBox.text = " Activada"
	else:
		%AccessibleFontCheckBox.text = " Desactivada"
	%WriteChatCheckBox.button_pressed = Config.chat_enabled
	if Config.chat_enabled:
		%WriteChatCheckBox.text = " Activada"
	else:
		%WriteChatCheckBox.text = " Desactivada"
	%BanTimeEditText.text = str(Config.ban_time)
	if Config.always_on_top:
		%AlwaysOnTopCheckBox.text = " Activada"
	else:
		%AlwaysOnTopCheckBox.text = " Desactivada"
	%AlwaysOnTopCheckBox.button_pressed = Config.always_on_top
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_ALWAYS_ON_TOP, Config.always_on_top)
	if Config.automatic_upload:
		%AutomaticUploadCheckBox.text = " Activada"
	else:
		%AutomaticUploadCheckBox.text = " Desactivada"
	%AutomaticUploadCheckBox.button_pressed = Config.automatic_upload
	%CommandEditText.text = Config.command

func book_pressed(button: BaseButton):
	book_changed.emit(button.get_parent().id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		hide()

func _on_check_box_toggled(button_pressed: bool):
	if button_pressed:
		%AccessibleFontCheckBox.text = " Activada"
	else:
		%AccessibleFontCheckBox.text = " Desactivada"
	Config.accessible_font = button_pressed
	redraw_window.emit()


func _on_volume_slider_value_changed(value: float):
	Config.volume = value
	AudioServer.set_bus_volume_db(master_index, linear_to_db(value / 100.0))

func _on_volume_slider_drag_started():
	%AudioStreamPlayer.stream_paused = false

func _on_volume_slider_drag_ended(value_changed):
	%AudioStreamPlayer.stream_paused = true

func _on_reset_button_pressed():
	%ConfirmationDialog.show()

func _on_deletion_dialog_confirmed():
	reset_all_data.emit()

func _on_hidden():
	Config.save_options()

func _on_write_chat_toggled(button_pressed):
	if button_pressed:
		%WriteChatCheckBox.text = " Activada"
	else:
		%WriteChatCheckBox.text = " Desactivada"
	Config.chat_enabled = button_pressed


func _on_ban_time_changed(new_text):
	if new_text.is_valid_int():
		Config.ban_time = int(new_text)


func _on_always_on_top_toggled(button_pressed):
	if button_pressed:
		%AlwaysOnTopCheckBox.text = " Activada"
	else:
		%AlwaysOnTopCheckBox.text = " Desactivada"
	Config.always_on_top = button_pressed
	DisplayServer.window_set_flag(DisplayServer.WindowFlags.WINDOW_FLAG_ALWAYS_ON_TOP, Config.always_on_top)


func _on_automatic_upload_toggled(button_pressed):
	if button_pressed:
		%AutomaticUploadCheckBox.text = " Activada"
	else:
		%AutomaticUploadCheckBox.text = " Desactivada"
	Config.automatic_upload = button_pressed


func _on_command_edit_text_text_changed(new_text : String):
	if new_text.strip_edges() != Config.command:
		Config.command = new_text.strip_edges()
