#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Spawner
extends Node3D




#===============================================================================
#	STATIC MEMBERS:
#===============================================================================
static var enemy_orca: Resource = preload("res://Enemy/Orca/orca.tscn")
static var enemy_types: Array = [enemy_orca]

const spawn_radius_min: float = 200.0
const spawn_radius_max: float = 1000.0
const MAX_COUNT_ENEMIES: int = 10


#===============================================================================
#	STATIC MEMBERS:
#===============================================================================
@export var wave_manager: WaveManager = null
@export var target: Node3D = null
@export var interval_spawn: float = 30.0
var _timeout_spawn: float = 0.0
var _enemies: Array[Node3D] = []


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if not target:
		return
	
	if Time.get_ticks_msec() < _timeout_spawn:
		return
	
	_timeout_spawn = Time.get_ticks_msec() + interval_spawn * 1000
	
	_cleaup_enemies()
	_spawn_enemy()


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
func _cleaup_enemies() -> void:
	for i in range(_enemies.size() - 1, -1, -1):
		if not _enemies[i]:
			_enemies.remove_at(i)


func _spawn_enemy() -> void:
	if _enemies.size() >= MAX_COUNT_ENEMIES:
		return
	
	var enemy_type: Resource = enemy_types[randi() % enemy_types.size()]
	var enemy = enemy_type.instantiate()
	get_tree().get_root().add_child(enemy)
	_enemies.push_back(enemy)
	
	if enemy is Orca:
		enemy.set_target(target)
		enemy.assign_wave_manager(wave_manager)
	
	var dir = Vector3.FORWARD.rotated(Vector3.UP, randf())
	var dist = randf_range(spawn_radius_min, spawn_radius_max)
	enemy.global_position = target.global_position + dir * dist
