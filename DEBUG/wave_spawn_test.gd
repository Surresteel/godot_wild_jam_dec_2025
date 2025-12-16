extends Node3D

var scene_wave = preload("res://Objects/Wave/wave.tscn")
@export var wm: WaveManager
@export var target: Node3D

var wave: Wave = null

func _physics_process(_delta: float) -> void:
	if not wave and wm:
		wave = scene_wave.instantiate()
		add_child(wave)
		wave.transform.origin = target.global_position + Vector3(0.0, 0.0, -50.0)
		wave.activate_wave(target.global_position, 20.0, 8.0, wm)
