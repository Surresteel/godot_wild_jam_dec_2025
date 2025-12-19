#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node


#===============================================================================
#	MEMBERS:
#===============================================================================
@onready var audio_stream_ambi := $AudioAmbient
@onready var audio_stream_music := $AudioMusic


func _ready() -> void:
	audio_stream_ambi.stream = AudioManager.WIND_AND_SEA_LOOPABLE
	audio_stream_ambi.play()
	
	audio_stream_music.stream = AudioManager.PIRATE_MUSIC
	audio_stream_music.play()
