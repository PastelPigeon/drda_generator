extends Button

func _pressed() -> void:
	# 当为弹窗时，不执行操作
	if owner.dialog:
		return
	
	# 最小化窗口
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
