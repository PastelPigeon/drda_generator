extends Label

func _process(delta: float) -> void:
	# 当动画能否播放状态未假时，设置文本并直接返回
	if %GeneratorPreview.get_canplay_state() == false:
		text = "无法播放"
		return
		
	# 当动画预览动画为空时，直接返回
	if %GeneratorPreview.get_preview_animation() == null:
		return
		
	# 设置文本
	text = "%s/%s 帧" % [int(%GeneratorPreview.animation_player_current_animation_position / %GeneratorPreview.get_preview_animation().step), int(%GeneratorPreview.get_preview_animation().length / %GeneratorPreview.get_preview_animation().step)]
