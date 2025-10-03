extends Panel

@export var is_dialog: bool = true ## 设置该窗口是否为应用内弹窗
@export var window_size: Vector2i = Vector2i(1000, 680) ## 窗口默认大小（仅在非应用内弹窗时有效）
@export var title: String ## 窗口标题
@export var icon: Texture ## 窗口图标
@export var is_extended_bar_enabled: bool = false ## 是否启用窗口拓展栏

# 窗口缩放相关参数
@export_group("Window Resize Settings")
@export var resize_border_thickness: int = 5 ## 缩放边框的厚度（像素）
@export var resize_corner_size: Vector2i = Vector2i(15, 15) ## 缩放角落的大小
@export var max_window_size: Vector2i = Vector2i(3840, 2160) ## 窗口最大尺寸
@export var min_window_size: Vector2i = Vector2i(400, 300) ## 窗口最小尺寸

# 鼠标样式常量
enum ResizeDirection {
	NONE = 0,
	LEFT = 1,
	RIGHT = 2,
	TOP = 4,
	BOTTOM = 8,
	TOP_LEFT = TOP | LEFT,
	TOP_RIGHT = TOP | RIGHT,
	BOTTOM_LEFT = BOTTOM | LEFT,
	BOTTOM_RIGHT = BOTTOM | RIGHT
}

# 缩放状态变量
var is_resizing: bool = false
var current_resize_direction: int = ResizeDirection.NONE
var resize_start_mouse_pos: Vector2
var resize_start_window_pos: Vector2
var resize_start_window_size: Vector2

# 配置文件路径
const CONFIG_PATH = "user://window_settings.cfg"

func _ready() -> void:
	# 非应用内弹窗，设置无边框窗口
	if is_dialog == false:
		_setup_borderless_window()
		
	# 非应用内弹窗，设置窗口大小
	if is_dialog == false:
		_load_window_settings()
		
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

func _process(_delta: float) -> void:
	if is_dialog:
		return
	
	# 更新鼠标样式
	_update_mouse_cursor()
	
	# 处理窗口缩放
	_handle_window_resize()

func _input(event: InputEvent) -> void:
	if is_dialog:
		return
	
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# 开始缩放
				if current_resize_direction != ResizeDirection.NONE:
					is_resizing = true
					resize_start_mouse_pos = get_global_mouse_position()
					resize_start_window_pos = DisplayServer.window_get_position()
					resize_start_window_size = DisplayServer.window_get_size()
			else:
				# 结束缩放并保存设置
				if is_resizing:
					is_resizing = false
					_save_window_settings()

func _handle_window_resize() -> void:
	if !is_resizing:
		return
	
	var current_mouse_pos = get_global_mouse_position()
	var mouse_delta = current_mouse_pos - resize_start_mouse_pos
	
	var new_position = resize_start_window_pos
	var new_size = resize_start_window_size
	
	# 根据缩放方向调整窗口位置和大小
	if current_resize_direction & ResizeDirection.LEFT:
		new_position.x += mouse_delta.x
		new_size.x -= mouse_delta.x
	elif current_resize_direction & ResizeDirection.RIGHT:
		new_size.x += mouse_delta.x
	
	if current_resize_direction & ResizeDirection.TOP:
		new_position.y += mouse_delta.y
		new_size.y -= mouse_delta.y
	elif current_resize_direction & ResizeDirection.BOTTOM:
		new_size.y += mouse_delta.y
	
	# 应用最小/最大尺寸限制
	new_size.x = clamp(new_size.x, min_window_size.x, max_window_size.x)
	new_size.y = clamp(new_size.y, min_window_size.y, max_window_size.y)
	
	# 如果调整了左边或上边，需要确保位置正确
	if current_resize_direction & ResizeDirection.LEFT:
		new_position.x = resize_start_window_pos.x + (resize_start_window_size.x - new_size.x)
	if current_resize_direction & ResizeDirection.TOP:
		new_position.y = resize_start_window_pos.y + (resize_start_window_size.y - new_size.y)
	
	# 应用新的窗口位置和大小
	DisplayServer.window_set_size(Vector2i(new_size))
	if current_resize_direction & (ResizeDirection.LEFT | ResizeDirection.TOP):
		DisplayServer.window_set_position(Vector2i(new_position))

func _update_mouse_cursor() -> void:
	if is_resizing:
		return
	
	var mouse_pos = get_global_mouse_position()
	var window_rect = Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	var resize_direction = _get_resize_direction(mouse_pos, window_rect)
	
	current_resize_direction = resize_direction
	
	# 设置对应的鼠标样式
	match resize_direction:
		ResizeDirection.LEFT, ResizeDirection.RIGHT:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_HSIZE)
		ResizeDirection.TOP, ResizeDirection.BOTTOM:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_VSIZE)
		ResizeDirection.TOP_LEFT, ResizeDirection.BOTTOM_RIGHT:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_FDIAGSIZE)
		ResizeDirection.TOP_RIGHT, ResizeDirection.BOTTOM_LEFT:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_BDIAGSIZE)
		_:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

func _get_resize_direction(mouse_pos: Vector2, window_rect: Rect2) -> int:
	var direction = ResizeDirection.NONE
	
	# 检查是否在边框区域内
	var left_rect = Rect2(0, 0, resize_border_thickness, window_rect.size.y)
	var right_rect = Rect2(window_rect.size.x - resize_border_thickness, 0, resize_border_thickness, window_rect.size.y)
	var top_rect = Rect2(0, 0, window_rect.size.x, resize_border_thickness)
	var bottom_rect = Rect2(0, window_rect.size.y - resize_border_thickness, window_rect.size.x, resize_border_thickness)
	
	# 检查是否在角落区域内
	var top_left_rect = Rect2(0, 0, resize_corner_size.x, resize_corner_size.y)
	var top_right_rect = Rect2(window_rect.size.x - resize_corner_size.x, 0, resize_corner_size.x, resize_corner_size.y)
	var bottom_left_rect = Rect2(0, window_rect.size.y - resize_corner_size.y, resize_corner_size.x, resize_corner_size.y)
	var bottom_right_rect = Rect2(window_rect.size.x - resize_corner_size.x, window_rect.size.y - resize_corner_size.y, resize_corner_size.x, resize_corner_size.y)
	
	# 确定缩放方向（角落优先于边框）
	if top_left_rect.has_point(mouse_pos):
		direction = ResizeDirection.TOP_LEFT
	elif top_right_rect.has_point(mouse_pos):
		direction = ResizeDirection.TOP_RIGHT
	elif bottom_left_rect.has_point(mouse_pos):
		direction = ResizeDirection.BOTTOM_LEFT
	elif bottom_right_rect.has_point(mouse_pos):
		direction = ResizeDirection.BOTTOM_RIGHT
	elif left_rect.has_point(mouse_pos):
		direction = ResizeDirection.LEFT
	elif right_rect.has_point(mouse_pos):
		direction = ResizeDirection.RIGHT
	elif top_rect.has_point(mouse_pos):
		direction = ResizeDirection.TOP
	elif bottom_rect.has_point(mouse_pos):
		direction = ResizeDirection.BOTTOM
	
	return direction

## 加载窗口设置
func _load_window_settings() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		var saved_size = config.get_value("window", "size", window_size)
		var saved_position = config.get_value("window", "position", Vector2i(100, 100))
		
		# 应用保存的窗口大小和位置
		DisplayServer.window_set_size(saved_size)
		DisplayServer.window_set_position(saved_position)
	else:
		# 使用默认设置
		DisplayServer.window_set_size(window_size)
		# 居中显示窗口
		var screen_size = DisplayServer.screen_get_size()
		var centered_position = (screen_size - window_size) / 2
		DisplayServer.window_set_position(centered_position)

## 保存窗口设置
func _save_window_settings() -> void:
	var config = ConfigFile.new()
	
	# 保存当前窗口大小和位置
	config.set_value("window", "size", DisplayServer.window_get_size())
	config.set_value("window", "position", DisplayServer.window_get_position())
	
	# 保存到文件
	config.save(CONFIG_PATH)

# 窗口关闭时自动保存设置
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if !is_dialog:
			_save_window_settings()
		get_tree().quit()
