extends Panel

@export var window_size: Vector2i = Vector2i(1000, 680) ## 窗口大小

func _ready() -> void:
	# 设置无边框
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	# 设置窗口大小
	DisplayServer.window_set_size(window_size)
	
	# 设置透明
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	get_tree().root.get_viewport().transparent_bg = true
