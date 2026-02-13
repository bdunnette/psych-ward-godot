extends Node2D

var grid_pos: Vector2i = Vector2i.ZERO
var target_grid_pos: Vector2i = Vector2i.ZERO
var move_speed: float = 2.0
var stability: float = 50.0

var type: String = "Patient" # Default
var data_index: int = -1

@onready var map: Node2D = get_parent().get_parent()

func _ready():
	# Initial position
	position = map.map_to_local(grid_pos)
	target_grid_pos = grid_pos
	GameManager.claim_tile(self, grid_pos)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_mouse = get_local_mouse_position()
		# ColorRect is offset_left = -10.0, offset_top = -20.0, offset_right = 10.0, offset_bottom = 0.0
		if local_mouse.x >= -10 and local_mouse.x <= 10 and local_mouse.y >= -20 and local_mouse.y <= 0:
			_on_clicked()

func _on_clicked():
	if type == "Patient":
		GameManager.medicate_patient(self)

func _process(delta):
	# Smooth movement to target
	var target_pos = map.map_to_local(target_grid_pos)
	position = position.lerp(target_pos, delta * move_speed)
	
	# Update emoji for patients based on stability
	if type == "Patient":
		_update_stability_emoji()
	
	# Hover effect
	var local_mouse = get_local_mouse_position()
	var exists_hover = local_mouse.x >= -10 and local_mouse.x <= 10 and local_mouse.y >= -20 and local_mouse.y <= 0
	var target_scale = Vector2(1.2, 1.2) if exists_hover else Vector2(1, 1)
	scale = scale.lerp(target_scale, delta * 10.0)
	
	if position.distance_to(target_pos) < 1.0:
		_decide_next_move()

func _update_stability_emoji():
	var label = get_node_or_null("Label")
	if label:
		if stability >= 75:
			label.text = "😊"
		elif stability >= 50:
			label.text = "😐"
		elif stability >= 25:
			label.text = "😟"
		else:
			label.text = "😰"

func _decide_next_move():
	if randf() > 0.95: # Small chance to pick a new target
		var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		dirs.shuffle() # Randomize direction order
		
		for dir in dirs:
			var next = grid_pos + dir
			
			# Bounds check
			if next.x < 0 or next.x >= map.grid_size or next.y < 0 or next.y >= map.grid_size:
				continue
				
			# Occupancy check
			if not GameManager.is_tile_occupied(next):
				GameManager.release_tile(grid_pos)
				grid_pos = next
				target_grid_pos = next
				GameManager.claim_tile(self, grid_pos)
				break
