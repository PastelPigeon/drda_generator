extends Panel

@export var is_dialog: bool = true ## 设置该窗口是否为应用内弹窗
@export var window_size: Vector2i = Vector2i(1000, 680) ## 窗口大小（仅在非应用内弹窗时有效）
@export var title: String ## 窗口标题
@export var icon: Texture ## 窗口图标
@export var is_extended_bar_enabled: bool = false ## 是否启用窗口拓展栏 

func _ready() -> void:
	# 非应用内弹窗，设置无边框窗口
	if is_dialog == false:
		_setup_borderless_window()
		
	# 非应用内弹窗，设置窗口大小
	if is_dialog == false:
		DisplayServer.window_set_size(window_size)
		
	# 设置标题
	%Title.text = title
	
	# 设置图标
	%Icon.texture = icon
	
	# 设置ExtendedBar
	%ExtendedBar.visible = is_extended_bar_enabled

## 初始化无边框窗口
func _setup_borderless_window():
	# 设置窗口无边框
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	# 设置窗口透明背景
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	get_tree().root.get_viewport().transparent_bg = true
