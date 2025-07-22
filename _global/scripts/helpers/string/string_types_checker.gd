extends Node

# 浮点数正则表达式（预编译）
var _float_regex: RegEx = _create_float_regex()
# 颜色函数正则表达式（预编译）
var _color_func_regex: RegEx = _create_color_func_regex()

func _create_float_regex() -> RegEx:
	var regex = RegEx.new()
	regex.compile("^[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?$")
	return regex

func _create_color_func_regex() -> RegEx:
	var regex = RegEx.new()
	regex.compile("^\\s*rgba?\\(\\s*\\d+\\s*,\\s*\\d+\\s*,\\s*\\d+\\s*(,\\s*[\\d\\.]+\\s*)?\\)\\s*$")
	return regex

# 检查是否为浮点数
func is_float_string(s: String) -> bool:
	return _float_regex.search(s) != null

# 检查是否为颜色值（Godot 4.4.1 兼容版本）
func is_color_string(s: String) -> bool:
	# 1. 检查十六进制格式
	if s.begins_with("#"):
		return Color.html_is_valid(s)
	
	# 2. 检查函数格式
	if _color_func_regex.search(s) != null:
		return true
	
	# 3. 检查命名颜色 - 使用 Godot 4 兼容方法
	var named_colors = _get_named_colors()
	if named_colors.has(s.to_lower()):
		return true
	
	return false

# 获取命名颜色字典（Godot 4 兼容实现）
func _get_named_colors() -> Dictionary:
	return {
		"aliceblue": true,
		"antiquewhite": true,
		"aqua": true,
		"aquamarine": true,
		"azure": true,
		"beige": true,
		"bisque": true,
		"black": true,
		"blanchedalmond": true,
		"blue": true,
		"blueviolet": true,
		"brown": true,
		"burlywood": true,
		"cadetblue": true,
		"chartreuse": true,
		"chocolate": true,
		"coral": true,
		"cornflower": true,
		"cornsilk": true,
		"crimson": true,
		"cyan": true,
		"darkblue": true,
		"darkcyan": true,
		"darkgoldenrod": true,
		"darkgray": true,
		"darkgreen": true,
		"darkkhaki": true,
		"darkmagenta": true,
		"darkolivegreen": true,
		"darkorange": true,
		"darkorchid": true,
		"darkred": true,
		"darksalmon": true,
		"darkseagreen": true,
		"darkslateblue": true,
		"darkslategray": true,
		"darkturquoise": true,
		"darkviolet": true,
		"deeppink": true,
		"deepskyblue": true,
		"dimgray": true,
		"dodgerblue": true,
		"firebrick": true,
		"floralwhite": true,
		"forestgreen": true,
		"fuchsia": true,
		"gainsboro": true,
		"ghostwhite": true,
		"gold": true,
		"goldenrod": true,
		"gray": true,
		"green": true,
		"greenyellow": true,
		"honeydew": true,
		"hotpink": true,
		"indianred": true,
		"indigo": true,
		"ivory": true,
		"khaki": true,
		"lavender": true,
		"lavenderblush": true,
		"lawngreen": true,
		"lemonchiffon": true,
		"lightblue": true,
		"lightcoral": true,
		"lightcyan": true,
		"lightgoldenrod": true,
		"lightgray": true,
		"lightgreen": true,
		"lightpink": true,
		"lightsalmon": true,
		"lightseagreen": true,
		"lightskyblue": true,
		"lightslategray": true,
		"lightsteelblue": true,
		"lightyellow": true,
		"lime": true,
		"limegreen": true,
		"linen": true,
		"magenta": true,
		"maroon": true,
		"mediumaquamarine": true,
		"mediumblue": true,
		"mediumorchid": true,
		"mediumpurple": true,
		"mediumseagreen": true,
		"mediumslateblue": true,
		"mediumspringgreen": true,
		"mediumturquoise": true,
		"mediumvioletred": true,
		"midnightblue": true,
		"mintcream": true,
		"mistyrose": true,
		"moccasin": true,
		"navajowhite": true,
		"navy": true,
		"oldlace": true,
		"olive": true,
		"olivedrab": true,
		"orange": true,
		"orangered": true,
		"orchid": true,
		"palegoldenrod": true,
		"palegreen": true,
		"paleturquoise": true,
		"palevioletred": true,
		"papayawhip": true,
		"peachpuff": true,
		"peru": true,
		"pink": true,
		"plum": true,
		"powderblue": true,
		"purple": true,
		"rebeccapurple": true,
		"red": true,
		"rosybrown": true,
		"royalblue": true,
		"saddlebrown": true,
		"salmon": true,
		"sandybrown": true,
		"seagreen": true,
		"seashell": true,
		"sienna": true,
		"silver": true,
		"skyblue": true,
		"slateblue": true,
		"slategray": true,
		"snow": true,
		"springgreen": true,
		"steelblue": true,
		"tan": true,
		"teal": true,
		"thistle": true,
		"tomato": true,
		"transparent": true,
		"turquoise": true,
		"violet": true,
		"wheat": true,
		"white": true,
		"whitesmoke": true,
		"yellow": true,
		"yellowgreen": true
	}
