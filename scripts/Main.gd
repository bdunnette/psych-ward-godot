extends Node2D

@onready var map = $Map
var patient_scene = preload("res://scenes/Patient.tscn")
var staff_scene = preload("res://scenes/Staff.tscn")

func _ready():
	GameManager.connect("stats_changed", _on_stats_changed)

func _on_stats_changed(_funds, _reputation):
	# Check if we need to spawn new sprites
	while map.get_node_or_null("Patients").get_child_count() < GameManager.patients.size():
		_spawn_patient()
		
	while map.get_node_or_null("Staff").get_child_count() < GameManager.staff.size():
		_spawn_staff()

func _spawn_patient():
	var pos = _get_empty_tile()
	if pos == Vector2i(-1, -1): return # No room!
	
	var p = patient_scene.instantiate()
	p.grid_pos = pos
	p.type = "Patient"
	p.data_index = map.get_node("Patients").get_child_count()
	map.get_node("Patients").add_child(p)

func _spawn_staff():
	var pos = _get_empty_tile()
	if pos == Vector2i(-1, -1): return
	
	var s = staff_scene.instantiate()
	s.grid_pos = pos
	s.type = "Staff"
	s.data_index = map.get_node("Staff").get_child_count()
	map.get_node("Staff").add_child(s)

func _get_empty_tile() -> Vector2i:
	var available = []
	for x in range(map.grid_size):
		for y in range(map.grid_size):
			var pos = Vector2i(x, y)
			if not GameManager.is_tile_occupied(pos):
				available.append(pos)
	
	if available.size() > 0:
		return available[randi() % available.size()]
	return Vector2i(-1, -1)
