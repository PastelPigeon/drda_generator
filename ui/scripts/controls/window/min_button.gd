extends Button

func _pressed() -> void:
	# 应用内弹窗不执行任何操作
	if owner.is_dialog:
		return
		
	# 最小化窗口
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
