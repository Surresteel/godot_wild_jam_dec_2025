extends CanvasLayer

@export var ship: Ship
@export var player: Player

@onready var ship_progress_icon: AnimatedSprite2D = $ProgressUI/ShipProgressBar
@onready var ship_health_BADRED: TextureRect = $ShipUI/ShipConditionBAD
@onready var ship_health_OKORANAGE: TextureRect = $ShipUI/ShipConditionOK
@onready var ship_health_GOODGREEN: TextureRect = $ShipUI/ShipConditionGOOD
@onready var snowball_3: TextureRect = $ReticleUI/Recticle3
@onready var snowball_2: TextureRect = $ReticleUI/Recticle2
@onready var snowball_1: TextureRect = $ReticleUI/Recticle1
@onready var ship_callout_front: TextureRect = $ShipUI/ShipAttackBacking/ShipAttackFront
@onready var ship_callout_back: TextureRect = $ShipUI/ShipAttackBacking/ShipAttackBack
@onready var ship_callout_left: TextureRect = $ShipUI/ShipAttackBacking/ShipAttackLeft
@onready var ship_callout_right: TextureRect = $ShipUI/ShipAttackBacking/ShipAttackRight


const PROGRESS_START: float = 377.0
const PROGRESS_END: float = 810.0

func _ready() -> void:
	call_deferred("_post_ready")

func _post_ready() -> void:
	ship.enemy_spotted.connect(_handle_callout)

func _process(_delta: float) -> void:
	_handle_progress()
	_handle_ammo()
	_handle_health()
	
func _handle_progress() -> void: 
	var progress = ship.get_progress_total() 
	ship_progress_icon.transform.origin.x = remap(progress,0.0,1.0,PROGRESS_START,PROGRESS_END)
	
func _handle_health() -> void:
	var health = ship.get_ship_health()
	if health >= 0.66:
		ship_health_GOODGREEN.visible = true
		ship_health_OKORANAGE.visible = false
		ship_health_BADRED.visible = false
	elif health >= 0.33:
		ship_health_OKORANAGE.visible = true
		ship_health_GOODGREEN.visible = false
		ship_health_BADRED.visible = false
	elif health < 0.33:
		ship_health_BADRED.visible = true
		ship_health_OKORANAGE.visible = false
		ship_health_GOODGREEN.visible = false
		
func _handle_ammo() -> void:
	if not player.snowball_action:
		return
	var ammo = player.snowball_action.ammo
	
	if ammo == 3:
		snowball_3.visible = true
		snowball_2.visible = false
		snowball_1.visible = false
	elif ammo == 2:
		snowball_2.visible = true
		snowball_3.visible = false
		snowball_1.visible = false
	elif ammo == 1:
		snowball_1.visible = true
		snowball_3.visible = false
		snowball_2.visible = false
	else:
		snowball_1.visible = false
		snowball_2.visible = false
		snowball_3.visible = false
		
	
func _handle_callout(sector: PenguinLookout.DIRECTIONS) -> void:
	
	if sector == PenguinLookout.DIRECTIONS.FORWARD: #Front
		_warning(ship_callout_front)
	elif sector == PenguinLookout.DIRECTIONS.AFT: #Back
		_warning(ship_callout_back)
	elif sector == PenguinLookout.DIRECTIONS.LEFT: #Left
		_warning(ship_callout_left)
	elif sector == PenguinLookout.DIRECTIONS.RIGHT: #Right
		_warning(ship_callout_right)

func _warning(texture: TextureRect) -> void:	
	for i in 5:
		texture.visible = true
		await get_tree().create_timer(0.8).timeout
		texture.visible = false
		await get_tree().create_timer(0.2).timeout
	
	
