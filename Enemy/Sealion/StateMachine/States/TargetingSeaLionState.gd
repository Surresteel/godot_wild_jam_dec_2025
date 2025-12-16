extends SealionBaseState
class_name TargetingSeaLionState

func enter(sealion: Sealion) -> void:
	sealion.animation_player.play("Penguin_Base/Penguin_Idle")

func exit(_sealion: Sealion) -> void:
	pass

func pre_update(sealion: Sealion) -> void:
	if not sealion.nav_agent.is_navigation_finished():
		sealion.change_state(SealionStates.WALKING)

func update(_sealion: Sealion, _delta) -> void:
	pass
