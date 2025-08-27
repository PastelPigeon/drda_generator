extends Node

# 系统主题方案枚举
enum SystemThemeScheme {LIGHT, DARK}

# 信号定义
signal system_theme_changed(new_scheme: SystemThemeScheme, new_accent_color: Color)
signal system_theme_scheme_changed(new_scheme: SystemThemeScheme)
signal system_theme_accent_color_changed(new_accent_color: Color)

# 当前系统主题和强调色
var _current_scheme: SystemThemeScheme = SystemThemeScheme.LIGHT
var _current_accent_color: Color = Color.WHITE

# 用于检测变化的计时器
var _poll_timer: Timer

# Windows 注册表路径和键名
const REGISTRY_PATH = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"
const THEME_KEY = "AppsUseLightTheme"

# Windows DWM 注册表路径
const DWM_REGISTRY_PATH = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\DWM"
const ACCENT_COLOR_KEY = "AccentColor"
const COLORIZATION_COLOR_KEY = "ColorizationColor"
const COLOR_PREVALENCE_KEY = "ColorPrevalence"

# 缓存上次检测的值以减少不必要的处理
var _last_theme_value: int = -1
var _last_accent_value: int = -1

func _ready():
	# 只在Windows平台上运行
	if OS.get_name() != "Windows":
		push_error("SystemThemeDetector only works on Windows platform")
		return
	
	# 初始化当前值
	_update_theme_values()
	
	# 创建并配置轮询计时器
	_poll_timer = Timer.new()
	_poll_timer.wait_time = 1.0  # 每秒检查一次
	_poll_timer.timeout.connect(_check_for_changes)
	add_child(_poll_timer)
	_poll_timer.start()

# 获取当前系统主题方案
func get_system_theme_scheme() -> SystemThemeScheme:
	return _current_scheme

# 获取当前系统强调色
func get_system_theme_accent_color() -> Color:
	return _current_accent_color

# 检查系统主题和强调色是否有变化
func _check_for_changes():
	_update_theme_values()

# 更新主题值
func _update_theme_values():
	var theme_changed = false
	var accent_changed = false
	
	# 检测主题变化
	var theme_value = _get_registry_value(REGISTRY_PATH, THEME_KEY)
	if theme_value != _last_theme_value:
		_last_theme_value = theme_value
		var new_scheme = SystemThemeScheme.DARK if theme_value == 0 else SystemThemeScheme.LIGHT
		if new_scheme != _current_scheme:
			_current_scheme = new_scheme
			theme_changed = true
	
	# 检测强调色变化
	var accent_value = _get_accent_color_value()
	
	if accent_value != _last_accent_value:
		_last_accent_value = accent_value
		var new_accent_color = _convert_windows_color(accent_value)
		
		if new_accent_color != _current_accent_color:
			_current_accent_color = new_accent_color
			accent_changed = true
	
	# 发出信号
	if theme_changed or accent_changed:
		if theme_changed:
			system_theme_scheme_changed.emit(_current_scheme)
		
		if accent_changed:
			system_theme_accent_color_changed.emit(_current_accent_color)
		
		system_theme_changed.emit(_current_scheme, _current_accent_color)

# 获取强调色值
func _get_accent_color_value() -> int:
	# 首先尝试获取 AccentColor
	var color_value = _get_registry_value(DWM_REGISTRY_PATH, ACCENT_COLOR_KEY)
	
	# 如果 AccentColor 为 0 或无效，尝试获取 ColorizationColor
	if color_value == 0:
		color_value = _get_registry_value(DWM_REGISTRY_PATH, COLORIZATION_COLOR_KEY)
	
	# 如果仍然没有有效的颜色值，使用默认颜色
	if color_value == 0:
		return _get_default_accent_color_value()
	
	return color_value

# 获取默认强调色值
func _get_default_accent_color_value() -> int:
	# Windows 默认强调色 (蓝色)
	return 0xFF0078D4  # ARGB格式: A=255, R=0, G=120, B=212

# 从注册表获取值
func _get_registry_value(path: String, key: String) -> int:
	var output = []
	var exit_code = OS.execute("reg", [
		"query", path, 
		"/v", key
	], output, true)
	
	if exit_code != 0 or output.size() == 0:
		return 0
	
	# 处理所有输出行
	for line in output:
		# 清理行中的控制字符
		var clean_line = _clean_string(line)
		
		if key in clean_line:
			# 查找十六进制值
			var parts = clean_line.split(" ")
			for part in parts:
				if part.begins_with("0x"):
					# 去掉"0x"前缀并清理任何非十六进制字符
					var hex_str = part.substr(2)
					hex_str = _clean_hex_string(hex_str)
					
					# 确保字符串只包含有效的十六进制字符
					if hex_str.is_valid_hex_number():
						return hex_str.hex_to_int()
					else:
						# 如果包含无效字符，尝试提取有效部分
						var valid_chars = ""
						for c in hex_str:
							if c in "0123456789ABCDEFabcdef":
								valid_chars += c
						if valid_chars.length() > 0:
							return valid_chars.hex_to_int()
			break
	
	return 0

# 清理字符串中的控制字符
func _clean_string(s: String) -> String:
	# 移除所有控制字符（ASCII 0-31）和多余空格
	var result = ""
	for i in range(s.length()):
		var char_code = s.unicode_at(i)
		if char_code > 31:  # 只保留非控制字符
			result += char(char_code)
	
	# 移除多余空格
	result = result.strip_edges()
	while "  " in result:
		result = result.replace("  ", " ")
	
	return result

# 清理十六进制字符串
func _clean_hex_string(s: String) -> String:
	var result = ""
	for i in range(s.length()):
		var c = s[i]
		if c in "0123456789ABCDEFabcdef":
			result += c
	return result

# 转换Windows颜色值为Godot Color
func _convert_windows_color(windows_color: int) -> Color:
	# Windows 使用 ABGR 格式 (Alpha, Blue, Green, Red)
	# 而不是通常的 ARGB 格式
	
	# 提取颜色分量
	var a = (windows_color >> 24) & 0xFF
	var b = (windows_color >> 16) & 0xFF
	var g = (windows_color >> 8) & 0xFF
	var r = windows_color & 0xFF
	
	# 转换为0-1范围的浮点数
	return Color(r / 255.0, g / 255.0, b / 255.0, a / 255.0)

# 停止检测
func stop_detection():
	if _poll_timer and _poll_timer.is_inside_tree():
		_poll_timer.stop()

# 重新开始检测
func start_detection():
	if _poll_timer and _poll_timer.is_inside_tree():
		_poll_timer.start()

# 清理资源
func _exit_tree():
	stop_detection()
