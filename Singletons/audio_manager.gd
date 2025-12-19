#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node


#===============================================================================
#	CLASS RESOURCES:
#===============================================================================
const WIND_AND_SEA_LOOPABLE = preload("uid://dlfqyjnuru215")
const SEA_SPRAY = preload("uid://b4nfb8pw1045v")
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
const SHIP_SOUNDS: Array[AudioStream] = \
[
	preload("uid://seg1smwel4y"),
	preload("uid://dw6qjy2ubyvn2"),
	preload("uid://dj10fp2x3uufv"),
	preload("uid://cmknb1yvd72gd"),
	preload("uid://cm0y2alb3c2tb"),
]
const ICE_SOUNDS: Array[AudioStream] = \
[
	preload("uid://j2os3y5ufsn7"),
	preload("uid://cbjskdewriwkg"),
	preload("uid://dgqqobq05wlur"),
	preload("uid://dt0y64gfpibsc"),
	
]

const ORCA_ATTACK_START = preload("uid://bh3t15t0du644")
const ORCA_JUMP = preload("uid://cigmoe7aughst")
const ORCA_ARRIVE = preload("uid://l7rskn6rv6vi")
