extends Node

var word_count : int = 0
var total_words : int
var users : Dictionary = {}

func compare_by_value(a: Dictionary, b: Dictionary) -> bool:
	if a["value"] < b["value"]:
		return true
	return false

func get_top_users_by_words() -> Array:
	var top_users : Array = []
	for user in users:
		top_users.append({"user": user, "value": users[user]["words"]})
	top_users.sort_custom(compare_by_value)
	return top_users.slice(0, 3)
