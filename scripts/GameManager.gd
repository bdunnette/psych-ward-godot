extends Node

# Signal for UI updates
signal stats_changed(funds, reputation)
signal log_added(message)

var funds: float = 25000.0
var reputation: float = 50.0
var grid_size: int = 10

var patients: Array = []
var staff: Array = []
var occupied_tiles: Dictionary = {}  # Maps Vector2i to Entity node


func _ready():
	# Start game loop timer
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.autostart = true
	timer.connect("timeout", _on_tick)
	add_child(timer)

	add_log("Ward opened successfully.")


func _on_tick():
	# 1. Calculate Resources
	var daily_salaries = 0
	for s in staff:
		daily_salaries += s.get("salary", 3000) / 30.0

	var occupancy_revenue = patients.size() * 150.0
	funds += occupancy_revenue - daily_salaries

	# 2. Update Patients Stability
	var patients_container = get_tree().get_first_node_in_group("patients_container")
	var staff_container = get_tree().get_first_node_in_group("staff_container")

	var rep_delta = 0
	for i in range(patients.size()):
		var p = patients[i]

		# Calculate distance-based stability modifier
		var distance_penalty = 0.0
		if patients_container and staff_container and i < patients_container.get_child_count():
			var patient_node = patients_container.get_child(i)
			var min_distance = INF

			# Find nearest staff member
			for staff_node in staff_container.get_children():
				var distance = patient_node.grid_pos.distance_to(staff_node.grid_pos)
				if distance < min_distance:
					min_distance = distance

			# Apply distance penalty
			# Close staff (0-2 tiles): +1 stability
			# Medium distance (3-5 tiles): 0 stability change
			# Far distance (6+ tiles): -2 to -4 stability decay
			if min_distance == INF:
				distance_penalty = -3.0  # No staff at all
			elif min_distance <= 2:
				distance_penalty = 1.0
			elif min_distance <= 5:
				distance_penalty = 0.0
			else:
				distance_penalty = -2.0 - (min_distance - 5) * 0.3
		else:
			distance_penalty = -2.0  # Default penalty if containers not found

		var shift = randf_range(-1, 1) + distance_penalty
		p.stability = clamp(p.stability + shift, 0, 100)

		# Update the visual entity if it exists
		_sync_patient_stability(i, p.stability)

		if p.stability < 25:
			rep_delta -= 0.3
		elif p.stability > 75:
			rep_delta += 0.1

	reputation = clamp(reputation + rep_delta, 0, 100)

	emit_signal("stats_changed", funds, reputation)


func _sync_patient_stability(index: int, new_stability: float):
	# Find the patient entity node and update its stability
	var patients_container = get_tree().get_first_node_in_group("patients_container")
	if patients_container and index < patients_container.get_child_count():
		var patient_node = patients_container.get_child(index)
		if patient_node:
			patient_node.stability = new_stability


func add_log(msg: String):
	print(msg)
	emit_signal("log_added", msg)


func admit_patient():
	if funds >= 500:
		funds -= 500
		var new_patient = {
			"name": "Patient " + str(patients.size() + 1),
			"stability": randf_range(40, 70),
			"condition": "General Observation"
		}
		patients.append(new_patient)
		add_log("New admission: " + new_patient.name)
		emit_signal("stats_changed", funds, reputation)
		return true
	return false


func hire_staff():
	if funds >= 2000:
		funds -= 2000
		var new_staff = {
			"name": "Staff " + str(staff.size() + 1),
			"role": "Caregiver",
			"efficiency": randf_range(50, 80),
			"salary": 3000
		}
		staff.append(new_staff)
		add_log("Hired: " + new_staff.name)
		emit_signal("stats_changed", funds, reputation)
		return true
	return false


func medicate_patient(patient_node):
	var idx = patient_node.data_index
	if idx >= 0 and idx < patients.size() and funds >= 100:
		funds -= 100
		patients[idx].stability = min(patients[idx].stability + 20, 100)
		patient_node.stability = patients[idx].stability
		add_log("Medicated " + patients[idx].name + " (-$100)")
		emit_signal("stats_changed", funds, reputation)
		return true
	return false


func is_tile_occupied(pos: Vector2i) -> bool:
	return occupied_tiles.has(pos)


func claim_tile(entity, pos: Vector2i):
	occupied_tiles[pos] = entity


func release_tile(pos: Vector2i):
	occupied_tiles.erase(pos)
