extends Control

signal exit
signal show_stats

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_mouse_exited()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_entered():
	%StatsButton.show()
	%SettingsButton.show()
	%ExitButton.show()
	%PauseButton.show()

func _on_mouse_exited():
	%StatsButton.hide()
	%SettingsButton.hide()
	%ExitButton.hide()
	%PauseButton.hide()


func _on_exit_button_pressed():
	exit.emit()


func _on_stats_button_pressed():
	show_stats.emit()
