extends Node2D

@export var tile_width: float = 64.0
@export var tile_height: float = 32.0
@export var grid_size: int = 10


func _draw():
	# Draw isometric grid for visualization
	var color = Color(0.2, 0.2, 0.3, 0.5)
	for x in range(grid_size + 1):
		var start = map_to_local(Vector2i(x, 0))
		var end = map_to_local(Vector2i(x, grid_size))
		draw_line(start, end, color, 1.0)

	for y in range(grid_size + 1):
		var start = map_to_local(Vector2i(0, y))
		var end = map_to_local(Vector2i(grid_size, y))
		draw_line(start, end, color, 1.0)


func map_to_local(map_pos: Vector2i) -> Vector2:
	var screen_x = (map_pos.x - map_pos.y) * (tile_width / 2.0)
	var screen_y = (map_pos.x + map_pos.y) * (tile_height / 2.0)
	return Vector2(screen_x, screen_y)
