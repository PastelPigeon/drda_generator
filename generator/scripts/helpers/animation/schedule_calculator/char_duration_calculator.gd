extends Node

## 计算单个字符的持续时间
func calculate_char_duration(token: Dictionary, fps: float) -> float:
	if token["char"] != "":
		# 当不是自闭合标签时
		if token["bbcode_tags"].has("delay"):
			# 当该字符含有delay标签时，使用delay的值作为字符时长
			return float(token["bbcode_tags"]["delay"]["value"])
		else:
			# 一般情况，字符时长取一帧
			return 1 / fps
	else:
		# 自闭合标签
		if token["bbcode_tags"].has("wait"):
			# wait自闭合控制标签
			return float(token["bbcode_tags"]["wait"]["value"])
		elif token["bbcode_tags"].has("off_screen"):
			# off_screen小对话框自闭合控制标签
			return 1 / fps * 2
		elif token["bbcode_tags"].has("options"):
			# options选项对话框自闭合控制标签
			return token["bbcode_tags"]["options"]["actions"].map(func (action): return float(action.split("|")[0])).reduce(func (a, num): return a + num)
		else:
			# 不支持的自闭合控制标签或无需特殊处理的自闭合控制标签跳过
			return 0
