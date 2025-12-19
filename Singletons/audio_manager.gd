#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node


#===============================================================================
#	CLASS RESOURCES:
#===============================================================================
const WIND_AND_SEA_LOOPABLE = preload("uid://dlfqyjnuru215")
const PIRATE_MUSIC = preload("uid://gf1p8kcfhfm")
const SHIP_CREAK = preload("uid://cm0y2alb3c2tb")
const WALK_SOUNDS: Array[AudioStream] = \
[
	preload("uid://dqrbncvsctkbj"),
	preload("uid://dw58ubd6u5eok"),
	preload("uid://j025v76iulmt"),
	preload("uid://cfnrd8jktbxmu"),
]
const CANNON_SOUNDS: Array[AudioStream] = \
[
	preload("uid://cstij2qbkktxu"),
	preload("uid://b0mxcea3rqqer"),
	preload("uid://h8erkrfjq1c7"),
	preload("uid://byefatqbiijeu"),
]
