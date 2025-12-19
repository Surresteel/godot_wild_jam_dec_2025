#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Spawner
extends Node




#===============================================================================
#	STATIC MEMBERS:
#===============================================================================
signal enemy_spawned(pos: Vector3, dir: Vector3)

const ENEMY_ORCA = preload("uid://m46fqntcnrhl")
const ENEMY_SEALION = preload("uid://b1nfl17a80wwi")
static var enemy_types: Array = [ENEMY_ORCA, ENEMY_SEALION]

const ICEBERG_DEFAULT = preload("uid://eu78vs6xjcuh")
const ICEBERG_SMALL = preload("uid://bcjxtpv4c6v00")
const ICEBERG_MEDIUM = preload("uid://diu5nca8q3pvn")
const ICEBERG_BIG = preload("uid://c4r781xe2va0x")
const ICEBERG_BIG_SIMPLE = preload("uid://veevvnfjh4wu")
const ICEBERG_DEFAULT_SIMPLE = preload("uid://bhhblklhw1p35")
const ICEBERG_MEDIUM_SIMPLE = preload("uid://c8xlavimdgrh5")
const ICEBERG_SMALL_SIMPLE = preload("uid://b52xa181uh7nx")

#static var iceberg_types: Array = [ICEBERG_DEFAULT, ICEBERG_SMALL, 
#		ICEBERG_MEDIUM, ICEBERG_BIG]
static var iceberg_types: Array = [ICEBERG_BIG_SIMPLE, ICEBERG_DEFAULT_SIMPLE, 
		ICEBERG_MEDIUM_SIMPLE, ICEBERG_SMALL_SIMPLE]

const spawn_radius_min_enemy: float = 500.0
const spawn_radius_max_enemy: float = 1000.0
const MAX_COUNT_ENEMIES: int = 20

const RAD_MIN_ICEBERG: float = 100.0
const RAD_MAX_ICEBERG: float = 400.0
const MAX_COUNT_ICEBERGS: int = 100


#===============================================================================
#	MEMBERS:
#===============================================================================
@export var target_count_enemties: int = 10

@export var init_count_iceberg: int = 10
@export var target_count_icebergs: int = 25

@export var wave_manager: WaveManager = null
@export var target: Node3D = null
@export var _interval_enemy: float = 30.0
@export var _interval_iceberg: float = 1.0
@export var enabled: = false
#@export var _target_count_icebergs: int = 100


var _timeout_enemy: float = 0.0
var _timeout_iceberg: float = 0.0
var _enemies: Array[Node3D] = []
#var _count_enemies: int = 0
var _count_icebergs: int = 0


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	call_deferred("_post_ready")


func _post_ready() -> void:
	for i in init_count_iceberg:
		_spawn_iceberg()


func _process(_delta: float) -> void:
	if not enabled:
		return
	
	if not target:
		return
	
	if Time.get_ticks_msec() >= _timeout_enemy:
		if _enemies.size() >= target_count_enemties:
			return
		_cleaup_enemies()
		_spawn_enemy()
		_timeout_enemy = Time.get_ticks_msec() + _interval_enemy * 1000
	
	if Time.get_ticks_msec() >= _timeout_iceberg:
		if _count_icebergs >= target_count_icebergs:
			return
		_spawn_iceberg()
		_timeout_iceberg = Time.get_ticks_msec() + _interval_iceberg * 1000


func _handle_iceberg_destroyed() -> void:
	_count_icebergs -= 1


func _handle_iceberg_split(layers: int, pos: Vector3, mult: int) -> void:
	for i in mult:
		_spawn_iceberg(layers, pos)


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
	
	if not enemy:
		return
	
	get_tree().current_scene.add_child(enemy)
	_enemies.push_back(enemy)
	
	if enemy is Orca:
		enemy.set_target(target)
		enemy.assign_wave_manager(wave_manager)
	if enemy is Sealion:
		enemy.set_target(target)
	
	var dir = Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU)
	var dist = randf_range(spawn_radius_min_enemy, spawn_radius_max_enemy)
	var pos = target.global_position + dir * dist
	enemy.global_position = pos
	enemy_spawned.emit(pos, dir)


## Spawns an iceberg around target, or pos_override, if set:
func _spawn_iceberg(layer_size: int = -1, pos_override: Variant = null) -> void:
	# GATE - max icebergs can't be reached:
	if _count_icebergs >= MAX_COUNT_ICEBERGS:
		return
	
	# Prepare for loop below:
	var index: int = randi() % iceberg_types.size()
	var iceberg: Variant = null
	var iceberg_found = false
	var attempts := 0
	var count := iceberg_types.size()
	
	# Find iceberg equal to layer_size:
	while not iceberg_found and attempts < count:
		var iceberg_type: Resource = iceberg_types[index]
		iceberg = iceberg_type.instantiate()
		
		if not iceberg:
			printerr("Spawning iceberg failed; unable to create instance.")
			return
		
		if layer_size == -1 or iceberg.onion_layers == layer_size:
			iceberg_found = true
		else:
			iceberg.queue_free()
			index = (index + 1) % count
			attempts += 1
	
	# GATE: - Valid iceberg must be found:
	if not iceberg_found:
		return
	
	# Connect to signals
	_count_icebergs += 1
	iceberg.iceberg_destroyed.connect(_handle_iceberg_destroyed)
	iceberg.iceberg_split.connect(_handle_iceberg_split)
	get_tree().current_scene.add_child(iceberg)
	iceberg.set_target(target)
	
	# Get iceberg spawn position:
	var pos := Vector3.ZERO
	if pos_override and pos_override is Vector3:
		pos = _rand_pos_rel(pos_override, 5.0, 10.0)
	elif target is RigidBody3D:
		pos = _get_spawn_pos_rel(target as RigidBody3D)
	pos.y = -10.0
	
	# Set iceberg position:
	iceberg.global_position = pos


## Gets a random position relative to another once between r_min and r_max dist:
func _rand_pos_rel(pos: Vector3, r_min: float, r_max: float) -> Vector3:
	var dir = Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU)
	var dist = randf_range(r_min, r_max)
	return pos + dir * dist


## Get a spawn position for icebergs around target:
func _get_spawn_pos_rel(tgt: RigidBody3D) -> Vector3:
	# Shape spawn arc by target's linear velocity:
	var tgt_speed = tgt.linear_velocity.length()
	var spawn_arc_size = remap(tgt_speed, 0.0, 5.0, 1.0, 0.4)
	spawn_arc_size = clampf(spawn_arc_size, 0.4, 1.0)
	
	# Randomly generate spawn direction:
	var tgt_fwd := -tgt.global_basis.z
	var spawn_side := (((randi() & 1 )* 2) - 1)
	var spawn_offset = spawn_side * randf() * PI * spawn_arc_size
	var dir = tgt_fwd.rotated(Vector3.UP, spawn_offset)
	
	# Randomly generate spawn distance:
	var shift = 100
	var lower = remap(tgt_speed, 0.0, 5.0, RAD_MIN_ICEBERG, RAD_MIN_ICEBERG 
			+ shift)
	var upper = remap(tgt_speed, 0.0, 5.0, RAD_MAX_ICEBERG - 2 * shift, 
			RAD_MAX_ICEBERG)
	lower = clampf(lower, RAD_MIN_ICEBERG, RAD_MAX_ICEBERG)
	upper = clampf(lower, RAD_MIN_ICEBERG, RAD_MAX_ICEBERG)
	var dist = randf_range(lower, upper)
	
	# Return position:
	return tgt.global_position + dir * dist
