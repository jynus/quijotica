extends Node

var word_count : int = 0
var total_words : int
var users : Dictionary = {}

const MAX_USERS : int = 10
const MIN_WORDS_FOR_ACCURACY : int = 10

func compare_by_value(a: Dictionary, b: Dictionary) -> bool:
	return a["value"] < b["value"] or (a["value"] == b["value"] and a["user"] < b["user"])

func compare_by_value_inverse(a: Dictionary, b: Dictionary) -> bool:
	return b["value"] < a["value"] or (a["value"] == b["value"] and a["user"] < b["user"])

func get_top_users_by_words() -> Array:
	var top_users : Array = []
	for user in users:
		top_users.append({"user": user, "value": users[user]["words"]})
	top_users.sort_custom(compare_by_value)
	return top_users.slice(0, MAX_USERS)

func get_top_users_by_speed() -> Array:
	var top_users : Array = []
	for user in users:
		if users[user]["words"] != 0:
			top_users.append({"user": user, "value": float(users[user]["time"]) / float(users[user]["words"])})

	top_users.sort_custom(compare_by_value_inverse)
	for user in top_users:
		user["value"] = float_format(user["value"]) + "s"
	return top_users.slice(0, MAX_USERS)

func get_top_users_by_accuracy() -> Array:
	var top_users : Array = []
	for user in users:
		if users[user]["errors"] > 0 or users[user]["words"] >= MIN_WORDS_FOR_ACCURACY:
			top_users.append({"user": user, "value": 100.0 * users[user]["words"] / (users[user]["words"] + users[user]["errors"])})
	top_users.sort_custom(compare_by_value)
	for user in top_users:
		user["value"] = pct_format(user["value"])
	return top_users.slice(0, MAX_USERS)
func get_top_users_by_errors() -> Array:
	var top_users : Array = []
	for user in users:
		top_users.append({"user": user, "value": users[user]["errors"]})
	top_users.sort_custom(compare_by_value)
	return top_users.slice(0, MAX_USERS)

func pct_format(value: float) -> String:
	return float_format(value) + " %"

func float_format(value: float) -> String:
	return "%.2f" % value

func get_global_status() -> Array:
	var total_participants : int = len(users)
	var valid_participants : int = 0
	var total_errors : int = 0
	var total_time : float = 0.0
	for user in users:
		total_errors += users[user]["errors"]
		total_time += users[user]["time"]
		if users[user]["words"] > 0:
			valid_participants += 1
	var average_time : float = total_time / word_count if word_count != 0 else 0.0
	var total_accuracy : float = 100.0 * word_count / (word_count + total_errors) if word_count != 0 else 0.0
	var global_stats : Array = [
		{"user": "Progreso", "value": str(word_count) + " de " + str(total_words) + " (" + pct_format(100.0 * word_count / total_words) + ")"},
		{"user": "Errores", "value": str(total_errors) + " (" + pct_format(total_accuracy) + " de aciertos)"},
		{"user": "Participantes", "value": str(total_participants)},
		{"user": "Participantes válidos", "value": str(valid_participants)},
		{"user": "Tiempo", "value": str(round(total_time)) + "s (" + float_format(average_time) + "s de media)"},
	]
	return global_stats	