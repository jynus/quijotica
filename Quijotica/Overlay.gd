extends Control

signal show_settings
signal show_stats
signal show_credits
signal show_rules

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_mouse_exited()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_entered():
	%StatsButton.show()
	%SettingsButton.show()
	%RulesButton.show()
	%CreditsButton.show()

func _on_mouse_exited():
	%StatsButton.hide()
	%SettingsButton.hide()
	%RulesButton.hide()
	%CreditsButton.hide()

func _on_stats_button_pressed():
	show_stats.emit()
