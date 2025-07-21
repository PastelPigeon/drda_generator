extends Node

## 合并多个字典（AI编写）
static func merge_dictionaries(
	dictionaries: Array[Dictionary],
	conflict_strategy: String = "overwrite",  # "overwrite"|"skip"|"merge_recursive"|"error"
	max_depth: int = -1,  # 递归深度限制，-1表示无限
	current_depth: int = 0
) -> Dictionary:
	var merged := {}
	
	# 检查递归深度
	if max_depth >= 0 and current_depth > max_depth:
		push_error("Dictionary merge reached max recursion depth")
		return merged
	
	for dict in dictionaries:
		if not dict:
			continue
			
		for key in dict:
			var value = dict[key]
			
			# 处理键冲突
			if merged.has(key):
				# 跳过已存在的键
				if conflict_strategy == "skip":
					continue
				
				# 抛出错误
				if conflict_strategy == "error":
					push_error("Key conflict detected: " + str(key))
					continue
				
				# 递归合并嵌套字典
				if conflict_strategy == "merge_recursive" and _can_merge_recursive(merged[key], value):
					merged[key] = merge_dictionaries(
						[merged[key], value],
						conflict_strategy,
						max_depth,
						current_depth + 1
					)
					continue
			
			# 直接覆盖或添加新键
			merged[key] = value
	
	return merged

# 检查是否可递归合并
static func _can_merge_recursive(a, b) -> bool:
	return typeof(a) == TYPE_DICTIONARY and typeof(b) == TYPE_DICTIONARY
