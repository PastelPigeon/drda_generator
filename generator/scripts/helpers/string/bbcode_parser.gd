extends Node

## 将bbcode字符串解析为token Array (AI代码)
func parse_bbcode_string_to_tokens(bbcode_string: String) -> Array:
	var tokens: Array = []
	var tag_stack: Array = []
	var current_tags: Dictionary = {}
	var char_index: int = 0
	var i: int = 0
	
	while i < bbcode_string.length():
		var char = bbcode_string[i]
		
		# 处理标签开始
		if char == "[":
			var end_index = bbcode_string.find("]", i)
			if end_index == -1:
				# 没有闭合括号，视为普通文本
				tokens.append(_create_token(char_index, char, current_tags.duplicate()))
				char_index += 1
				i += 1
				continue
			
			var tag_content = bbcode_string.substr(i + 1, end_index - i - 1)
			i = end_index + 1
			
			# 检查是否是自闭合标签 (以 /] 结尾)
			var is_self_closing = tag_content.strip_edges().ends_with("/")
			if is_self_closing:
				# 移除末尾的斜杠
				tag_content = tag_content.substr(0, tag_content.length() - 1).strip_edges()
			
			# 处理结束标签
			if tag_content.begins_with("/"):
				var tag_name = tag_content.substr(1).strip_edges()
				if tag_stack.size() > 0 and tag_stack.back()[0] == tag_name:
					tag_stack.pop_back()
					_update_current_tags(tag_stack, current_tags)
				continue
			
			# 处理开始标签或自闭合标签
			var tag_data = _parse_tag(tag_content)
			
			if is_self_closing:
				# 创建包含所有外层标签的字典
				var combined_tags = current_tags.duplicate(true)
				
				# 确保自闭合标签作为字典中的第一个键
				var ordered_dict = {}
				ordered_dict[tag_data.name] = tag_data.attrs
				
				# 添加外层标签（避免覆盖自闭合标签）
				for key in combined_tags:
					if key != tag_data.name:
						ordered_dict[key] = combined_tags[key]
				
				# 创建自闭合标签的token
				tokens.append(_create_token(char_index, "", ordered_dict))
				char_index += 1  # 自闭合标签占用一个字符位置
			else:
				tag_stack.append([tag_data.name, tag_data.attrs])
				_update_current_tags(tag_stack, current_tags)
			continue
		
		# 处理普通字符
		if char != "\t" and char != "\n":
			tokens.append(_create_token(char_index, char, current_tags.duplicate(true)))
			char_index += 1
		
		i += 1
	
	return tokens

# 创建token字典
func _create_token(index: int, char: String, tags: Dictionary) -> Dictionary:
	return {
		"char_index": index,
		"char": char,
		"bbcode_tags": tags
	}

# 更新当前有效标签
func _update_current_tags(stack: Array, current_tags: Dictionary) -> void:
	current_tags.clear()
	for tag in stack:
		var tag_name = tag[0]
		var tag_attrs = tag[1]
		current_tags[tag_name] = tag_attrs

# 解析标签内容
func _parse_tag(content: String) -> Dictionary:
	var result = { name = "", attrs = {} }
	var parts = content.split(" ", false)
	
	if parts.size() > 0:
		result.name = parts[0].strip_edges()
	
	# 处理无名属性 (如 [color=green])
	if "=" in result.name:
		var name_value = result.name.split("=", false, 1)
		result.name = name_value[0]
		result.attrs["value"] = _parse_value(name_value[1])
	
	# 处理命名属性
	for j in range(1, parts.size()):
		var attr_pair = parts[j].split("=", false, 1)
		if attr_pair.size() == 2:
			var key = attr_pair[0].strip_edges()
			var value_str = attr_pair[1].strip_edges()
			
			# 检查是否是尖括号包裹的数组值
			if value_str.begins_with("<") and value_str.ends_with(">"):
				var array_content = value_str.substr(1, value_str.length() - 2)
				result.attrs[key] = _parse_array_value(array_content)
			else:
				result.attrs[key] = _parse_value(value_str)
	
	return result

# 解析数组值
func _parse_array_value(array_str: String) -> Array[String]:
	var result: Array[String] = []
	var items = array_str.split(",", false)
	
	for item in items:
		result.append(item.strip_edges())
	
	return result

# 转换属性值类型
func _parse_value(value_str: String) -> Variant:
	if value_str.is_valid_int():
		return value_str.to_int()
	if value_str.is_valid_float():
		return value_str.to_float()
	if value_str.is_valid_html_color():
		return value_str
	return value_str
