extends Node

## 所有控制标签（删除extra_duration）
const CONTROLLER_TAGS = [
	"world_state",
	"face",
	"sound",
	"delay",
	"wait",
	"disable_sound",
	"dialogue_display_mode"
]

## 从dialogue中删除bbcode标签（当bbcode_tags留空时，删除所有标签）
func clean_bbcode_tags_from_dialogue(dialogue: String, bbcode_tags: Array = []) -> String:
	if len(bbcode_tags) == 0:
		# 当bbcode_tags为空时，删除所有标签
		# 创建正则表达式对象
		var regex = RegEx.new()
		
		# 编译匹配BBCode标签的正则表达式（包括开闭标签）
		var compile_result = regex.compile("\\[.*?\\]")
		if compile_result != OK:
			push_error("RegEx编译失败: " + str(compile_result))
			return dialogue
		
		# 替换所有匹配的标签为空字符串
		return regex.sub(dialogue, "", true)
	else:
		# 当bbcode_tags不为空时，删除指定标签
		var result = dialogue
		var regex = RegEx.new()
			
		# 构建匹配所有指定标签的正则表达式
		var pattern_parts = []
		for tag in bbcode_tags:
			# 匹配所有形式的标签：
			# 1. 开始标签：[tag] 或 [tag=value] 或 [tag key=value]
			# 2. 结束标签：[/tag]
			# 3. 自闭合标签：[tag/] 或 [tag=value/] 或 [tag key=value /]
			var tag_pattern = (
				"\\["  # 开始括号
				+ "(/?)"  # 可能的斜杠（用于结束标签）
				+ tag  # 标签名
				+ "\\b"  # 单词边界，防止匹配类似标签
				+ "(?:\\s*[^\\]\\s]*\\s*)*?"  # 允许属性值包含空格和特殊字符
				+ "(/?)"  # 可能的自闭合斜杠
				+ "\\]"  # 结束括号
			)
			pattern_parts.append(tag_pattern)
		
		# 组合所有标签模式
		var pattern = "|".join(pattern_parts)
		
		# 编译正则表达式
		var error = regex.compile(pattern)
		if error != OK:
			push_error("Failed to compile regex: " + pattern)
			return dialogue
			
		# 执行替换
		result = regex.sub(result, "", true)
		
		return result
