extends Node

enum ThemeScheme { LIGHT, DARK }

# 基础主题资源路径
const BASE_LIGHT_THEME_PATH = "res://ui/assets/themes/default_light.tres"
const BASE_DARK_THEME_PATH = "res://ui/assets/themes/default_dark.tres"

# 需要替换的特定颜色路径列表
const COLOR_PATHS_TO_REPLACE = [
	# 原始主题中的黄色强调色路径
	"asset_type_switcher_switcher_item_list/colors/font_hovered_selected_color",
	"asset_type_switcher_switcher_item_list/colors/font_selected_color",
	"assets_viewer_assets_tree/colors/font_selected_color",
	"content_err_msg_label_err/colors/font_color",
	"content_err_msg_label_ok/colors/font_color",
	"pages_nav_button_current_page/colors/font_color",
	"pages_nav_button_current_page/colors/font_focus_color",
	# StyleBox中的颜色
	"title_bar/styles/panel" # 这是StyleBoxFlat_365c8的引用
]

# 生成动态主题
static func generate_dynamic_theme(scheme: ThemeScheme, accent_color: Color) -> Theme:
	var base_theme: Theme
	
	# 根据主题方案选择基础主题
	match scheme:
		ThemeScheme.LIGHT:
			base_theme = load(BASE_LIGHT_THEME_PATH).duplicate(true)
		ThemeScheme.DARK:
			base_theme = load(BASE_DARK_THEME_PATH).duplicate(true)
		_:
			push_error("Invalid theme scheme")
			return null
	
	# 替换主题中的强调色
	_replace_accent_colors(base_theme, accent_color)
	
	return base_theme

# 替换主题中的强调色
static func _replace_accent_colors(theme: Theme, accent_color: Color) -> void:
	# 替换特定路径的颜色
	for color_path in COLOR_PATHS_TO_REPLACE:
		var parts = color_path.split("/")
		var type = parts[0]
		var category = parts[1]
		var property = parts[2]
		
		if category == "colors":
			# 设置颜色属性
			theme.set_color(property, type, accent_color)
		elif category == "styles":
			# 处理StyleBox
			var stylebox = theme.get_stylebox(property, type)
			if stylebox is StyleBoxFlat:
				_replace_stylebox_accent_color(stylebox as StyleBoxFlat, accent_color)

# 替换StyleBox中的强调色
static func _replace_stylebox_accent_color(stylebox: StyleBoxFlat, accent_color: Color) -> void:
	# 检查当前颜色是否为需要替换的强调色
	# 这里我们假设所有StyleBoxFlat的bg_color都是需要替换的强调色
	# 在实际应用中，您可能需要更精确的逻辑
	stylebox.bg_color = accent_color

# 辅助函数：检查颜色是否为需要替换的强调色
static func _is_accent_color_to_replace(color: Color) -> bool:
	# 这里列出原始主题中需要替换的强调色值
	var accent_colors = [
		Color(0.976471, 0.505882, 0, 1), # 原始橙色
		Color(0.698039, 0.698039, 0, 1), # 原始黄色
		Color(0.696525, 0.696525, 0, 1)  # 原始黄色变体
	]
	
	for accent_color in accent_colors:
		if color.is_equal_approx(accent_color):
			return true
	
	return false
