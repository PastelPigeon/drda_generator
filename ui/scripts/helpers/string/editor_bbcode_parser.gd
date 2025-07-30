extends Node

enum BbcodeStringError {
	NONE,               # 没有错误
	UNCLOSED_TAG,       # 标签未闭合
	UNOPENED_TAG,       # 结束标签没有对应的开始标签
	MISMATCHED_TAG,     # 开始和结束标签不匹配
	INVALID_TAG_FORMAT, # 标签格式无效
	INVALID_SELF_CLOSING # 自闭合标签格式无效
}

# 补全省略的结束标签
static func complete_bbcode_string_end_tags(bbcode_string: String) -> String:
	var stack = []  # 存储打开标签的栈
	var result = PackedStringArray()  # 存储结果字符串数组
	var i = 0
	
	while i < bbcode_string.length():
		var char = bbcode_string[i]
		
		# 处理标签开始
		if char == "[":
			var end_index = bbcode_string.find("]", i)
			if end_index == -1:
				# 没有闭合括号，直接添加到结果
				result.append(bbcode_string.substr(i))
				break
			
			var tag_content = bbcode_string.substr(i + 1, end_index - i - 1)
			var full_tag = "[" + tag_content + "]"
			
			# 检查是否是结束标签
			if tag_content.begins_with("/"):
				var tag_name = tag_content.substr(1).strip_edges()
				
				# 处理省略的结束标签 [/]
				if tag_name == "":
					if stack.size() > 0:
						var last_tag = stack.pop_back()
						result.append("[/" + last_tag + "]")
					else:
						result.append(full_tag)  # 没有可匹配的标签，保留原样
				else:
					# 完整结束标签，检查是否匹配
					if stack.size() > 0 and stack.back() == tag_name:
						stack.pop_back()
					result.append(full_tag)
			# 检查是否是自闭合标签
			elif tag_content.strip_edges().ends_with("/"):
				result.append(full_tag)
			# 处理开始标签
			else:
				# 提取标签名
				var tag_name = tag_content.split(" ")[0].strip_edges()
				# 处理无名属性 (如 [color=green])
				if "=" in tag_name:
					tag_name = tag_name.split("=")[0]
				
				stack.append(tag_name)
				result.append(full_tag)
			
			i = end_index + 1
			continue
		
		# 普通字符
		result.append(char)
		i += 1
	
	# 添加所有未闭合的结束标签
	while stack.size() > 0:
		var tag_name = stack.pop_back()
		result.append("[/" + tag_name + "]")
	
	return "".join(result)

# 检查 BBCode 字符串是否存在语法问题
static func check_bbcode_string(bbcode_string: String) -> BbcodeStringError:
	var stack = []  # 存储打开标签的栈
	var i = 0
	
	while i < bbcode_string.length():
		var char = bbcode_string[i]
		
		if char == "[":
			var end_index = bbcode_string.find("]", i)
			if end_index == -1:
				return BbcodeStringError.INVALID_TAG_FORMAT
			
			var tag_content = bbcode_string.substr(i + 1, end_index - i - 1)
			
			# 处理结束标签
			if tag_content.begins_with("/"):
				var tag_name = tag_content.substr(1).strip_edges()
				
				# 省略的结束标签 [/] - 需要补全
				if tag_name == "":
					if stack.size() == 0:
						return BbcodeStringError.UNOPENED_TAG
					stack.pop_back()
				else:
					if stack.size() == 0:
						return BbcodeStringError.UNOPENED_TAG
					
					var last_tag = stack.pop_back()
					if last_tag != tag_name:
						return BbcodeStringError.MISMATCHED_TAG
			
			# 处理自闭合标签
			elif tag_content.strip_edges().ends_with("/"):
				# 检查自闭合标签格式是否正确
				if not tag_content.ends_with("/"):
					return BbcodeStringError.INVALID_SELF_CLOSING
				# 自闭合标签不需要入栈
			
			# 处理开始标签
			else:
				# 提取标签名
				var tag_name = tag_content.split(" ")[0].strip_edges()
				# 处理无名属性 (如 [color=green])
				if "=" in tag_name:
					tag_name = tag_name.split("=")[0]
				
				# 检查标签名是否有效
				if tag_name.strip_edges() == "":
					return BbcodeStringError.INVALID_TAG_FORMAT
				
				stack.append(tag_name)
			
			i = end_index + 1
		else:
			i += 1
	
	# 检查未闭合的标签
	if stack.size() > 0:
		return BbcodeStringError.UNCLOSED_TAG
	
	return BbcodeStringError.NONE

# 辅助函数：将错误代码转换为可读字符串
static func error_to_string(error: BbcodeStringError) -> String:
	match error:
		BbcodeStringError.NONE:
			return "无错误"
		BbcodeStringError.UNCLOSED_TAG:
			return "检测到未闭合标签"
		BbcodeStringError.UNOPENED_TAG:
			return "没有开始标签的闭合标签"
		BbcodeStringError.MISMATCHED_TAG:
			return "开始标签与闭合标签不匹配"
		BbcodeStringError.INVALID_TAG_FORMAT:
			return "错误的标签形式"
		BbcodeStringError.INVALID_SELF_CLOSING:
			return "错误的自闭合标签形式"
		_:
			return "未知错误"
