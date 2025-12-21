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
const THROW_SOUNDS: Array[AudioStream] = \
[
	preload("uid://q141umn5p5j6"),
	preload("uid://bi58x13eykke3"),
	preload("uid://c82jlpj43wi0m"),
]

const ORCA_ATTACK_START = preload("uid://bh3t15t0du644")
const ORCA_JUMP = preload("uid://cigmoe7aughst")
const ORCA_ARRIVE = preload("uid://l7rskn6rv6vi")
const ORCA_EXPLOSIONS: Array[AudioStream] = \
[
	preload("uid://fa12rdy8fv58"),
	preload("uid://b8bhqcumd7hmk"),
	preload("uid://ddqsj6ydywtdx"),
]

const WAVE_SOUNDS: Array[AudioStream] = \
[
	preload("uid://c45cmq7kr3msu"),
	preload("uid://enl3c2kgppbf"),
	preload("uid://3gdxg2f22pyw"),
	preload("uid://b6ov6ngl43w8x"),
	preload("uid://b0s1xvxorhnj3"),
	preload("uid://bo75pv62uqpej"),
]

const CRASH_SOUNDS: Array[AudioStream] = \
[
	preload("uid://ckvditi8elblg"),
	preload("uid://b7f4lbcopm3yv"),
]

const PENGUIN_EAST = preload("uid://dib6iqe6dh6lp")
const PENGUIN_NORTH = preload("uid://bpcpqeeshysop")
const PENGUIN_SOUTH = preload("uid://cqwfo87w8hsr0")
const PENGUIN_WEST = preload("uid://k5umegh7rai4")
const WAVE_INCOMING = preload("uid://ch5fhuuy0sccy")
const PUNCH = preload("uid://sa1xkciyy3ls")

const SEALION_GRUNT = preload("uid://cu425cdlsei3t")
const SEALION_DEATH = preload("uid://cn06xh0157jie")
const SEALION_HIT = preload("uid://61vmwt0mi63h")
