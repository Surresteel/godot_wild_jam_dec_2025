#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node3D


#===============================================================================
#	NODE INITIALISATION:
#===============================================================================
# Preloaded scenes:
var scene_water = preload("res://Objects/WaterTile/water.tscn")


# Constants:
var GRID_SIZE: int = 128
var GRID_RADIUS: int = 5


# Grid Management:
var grid_pos: Vector2i
var grid_tiles: Array[Node3D]


# Children:
@onready var ship: Ship = $Ship


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	call_deferred("_ready_post")
	_create_sea_grid()


func _ready_post() -> void:
	Water.set_water_colour_dark(Vector3(0.0, 0.2, 0.5))
	Water.set_water_colour_light(Vector3(0.0, 0.3, 0.5))
	Water.set_water_colour_foam(Vector3(0.5, 0.5, 1.0))
	Water.set_wave_frequency(3.0)
	Water.set_wave_amplitude(0.4)
	Water.set_wave_speed(0.25)


func _process(_delta: float) -> void:
	# GATE: - Ship must have moved to generate new tiles.
	if (grid_pos == _world_to_grid(ship.global_position)):
		return
	
	# Update ship grid position and generate tiles.
	grid_pos = _world_to_grid(ship.global_position)
	_update_sea_grid()


func _physics_process(_delta: float) -> void:
	# DEBUG:
	#ship.move_forwards()
	Water.advance_time()
	# DEBUG:

#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
func _create_sea_grid() -> void:
	grid_pos = _world_to_grid(ship.global_position)
	var instance: Node3D = scene_water.instantiate()
	add_child(instance)
	instance.transform.origin = _grid_to_world(grid_pos)
	grid_tiles.push_back(instance)
	_spawn_tiles()


func _update_sea_grid() -> void:
	for i in range(grid_tiles.size() - 1, -1, -1):
		var tile_pos = _world_to_grid(grid_tiles[i].transform.origin)
		if _grid_distance(tile_pos, grid_pos) >= 2:
			grid_tiles[i].queue_free()
			grid_tiles.remove_at(i)
	
	_spawn_tiles()


func _spawn_tiles() -> void:
	for i in GRID_RADIUS:
		if i == 0:
			continue
			
		var leng: int = 2 * i
		@warning_ignore("narrowing_conversion")
		var cur_pos := Vector2i(grid_pos.x - leng*0.5, grid_pos.y + leng*0.5)
		var dir := Vector2i(0, 1)
		for y in leng * 4:
			if y % leng == 0:
				dir = Vector2i(dir.y, -dir.x)
			
			cur_pos += dir
			var new_pos := cur_pos
			if _tile_exists(new_pos):
				continue
			
			var instance: Node3D = scene_water.instantiate()
			add_child(instance)
			instance.transform.origin = _grid_to_world(new_pos)
			grid_tiles.push_back(instance)


func _tile_exists(pos: Vector2i) -> bool:
	for tile in grid_tiles:
		var tile_pos := _world_to_grid(tile.global_position)
		if pos == tile_pos:
			return true
	return false


func _world_to_grid(pos: Vector3) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(floori(pos.x / GRID_SIZE), floori(pos.z / GRID_SIZE))


func _grid_to_world(pos: Vector2i) -> Vector3:
	return Vector3((pos.x + 0.5) * GRID_SIZE, 0.0, (pos.y + 0.5) * GRID_SIZE)


func _grid_distance(p1: Vector2i, p2: Vector2i) -> int:
	return max(abs(p2.x - p1.x), abs(p2.y - p1.y))


#===============================================================================
#	EOF:
#===============================================================================
