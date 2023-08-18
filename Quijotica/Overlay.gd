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
	%Container2.show()
	%ColorRect.show()
	%ColorRect2.show()
	%ColorRect3.show()
	%ColorRect4.show()
	%StatsButton.show()
	%SettingsButton.show()
	%RulesButton.show()
	%CreditsButton.show()

func _on_mouse_exited():
	%Container2.hide()
	%ColorRect.hide()
	%ColorRect2.hide()
	%ColorRect3.hide()
	%ColorRect4.hide()
	%StatsButton.hide()
	%SettingsButton.hide()
	%RulesButton.hide()
	%CreditsButton.hide()

func _on_stats_button_pressed():
	show_stats.emit()

func _on_settings_button_pressed():
	show_settings.emit()

func _on_credits_button_pressed():
	show_credits.emit()

func _on_rules_button_pressed():
	show_rules.emit()
