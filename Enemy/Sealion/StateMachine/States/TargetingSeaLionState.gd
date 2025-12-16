extends SealionBaseState
class_name TargetingSeaLionState

func enter(_sealion: Sealion) -> void:
	pass

func exit(_sealion: Sealion) -> void:
	pass

func pre_update(sealion: Sealion) -> void:
	if not sealion.nav_agent.is_navigation_finished():
		sealion.change_state(SealionStates.WALKING)

func update(_sealion: Sealion, _delta) -> void:
	pass
