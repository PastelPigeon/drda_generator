extends Button

func _pressed() -> void:
	# 最小化窗口
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
