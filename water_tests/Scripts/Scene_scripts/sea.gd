#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node3D


#===============================================================================
#	NODE INITIALISATION:
#===============================================================================
# Preloaded scenes:
var scene_water = preload("res://water_tests/Scenes/water.tscn")


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
	_create_sea_grid()


func _process(_delta: float) -> void:
	ship.move_forwards()
	
	if (grid_pos == _world_to_grid(ship.global_position)):
		return
	
	grid_pos = _world_to_grid(ship.global_position)
	_update_sea_grid()


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
			
		var edge_length: int = 2 * i
		@warning_ignore("narrowing_conversion")
		var cur_pos := Vector2i(grid_pos.x - edge_length*0.5, grid_pos.y + edge_length*0.5)
		var dir := Vector2i(0, 1)
		for y in edge_length * 4:
			if y % edge_length == 0:
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


func _grid_to_world(coords: Vector2i) -> Vector3:
	return Vector3((coords.x + 0.5) * GRID_SIZE, 0.0, (coords.y + 0.5) * GRID_SIZE)


func _grid_distance(p1: Vector2i, p2: Vector2i) -> int:
	#return abs(p2.x - p1.x) + abs(p2.y - p1.y)
	return max(abs(p2.x - p1.x), abs(p2.y - p1.y))
