extends CanvasLayer

@onready var funds_label = $Control/HBoxContainer/Funds
@onready var rep_label = $Control/HBoxContainer/Reputation
@onready var log_list = $Control/LogPanel/VBoxContainer


func _ready():
	GameManager.connect("stats_changed", _on_stats_changed)
	GameManager.connect("log_added", _on_log_added)
	_on_stats_changed(GameManager.funds, GameManager.reputation)


func _on_stats_changed(funds, reputation):
	funds_label.text = "Funds: $" + str(round(funds))
	rep_label.text = "Reputation: " + str(round(reputation)) + "%"


func _on_log_added(msg):
	var label = Label.new()
	label.text = msg
	label.add_theme_font_size_override("font_size", 12)
	log_list.add_child(label)
	# Keep only last 10 logs
	if log_list.get_child_count() > 10:
		log_list.get_child(0).queue_free()


func _on_admit_pressed():
	GameManager.admit_patient()


func _on_hire_pressed():
	GameManager.hire_staff()
