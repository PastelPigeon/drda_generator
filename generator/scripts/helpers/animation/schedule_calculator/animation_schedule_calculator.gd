extends Node

## 从给定的对话列表中计算出来动画的时间表
func calculate_animation_schedule(dialogues: Array, fps: float) -> Dictionary:
	# 初始化所有对话的信息记录变量
	var total_duration = 0 ## 动画总时长
	var dialogue_schedules = [] ## 对话的时间表数据
	
	# 遍历dialogues数组
	for dialogue in dialogues:
		# 初始化单个对话的信息记录变量
		var dialogue_duration = 0 ## 单个对话的动画总时长
		var char_schedules = [] ## 字符的时间表数据
		
		# 将该对话解析为token数组
		var tokens = BbcodeParser.parse_bbcode_string_to_tokens(dialogue)
		
		# 遍历token数组获取单个字符的时间数据
		for token in tokens:
			# 计算单个字符的时长
			var char_duration = CharDurationCalculator.calculate_char_duration(token, fps)
				
			# 将单个字符的时间表数据添加到char_schedules中
			char_schedules.append(
				{
					"index": tokens.find(token), # 当前字符的位置
					"duration": char_duration, # 当前字符的持续时长
					"relative_start_time": dialogue_duration, # 相对于该对话的开始时间的字符动画开始时间（为上一字符结束时间）
					"relative_end_time": dialogue_duration + char_duration - 1 / fps, # 相对结束时间（比实际时长少一帧，与下个字符错开，只有一帧的字符开始时间与结束时间重叠）
					"absolute_start_time": total_duration + dialogue_duration, # 加上已计算的总时长的绝对字符开始时间，为最终该字符在动画中的时间，可以直接使用
					"absolute_end_time": total_duration + dialogue_duration + char_duration - 1 / fps # 绝对结束时间
				}
			)
			
			# 将该字符的持续时间加入该对话动画的总持续时间
			dialogue_duration += char_duration
		
		# extra_duration控制标签已弃用
		# 处理特殊的extra_duration额外时长控制标签（按该对话第一个字符的extra_duration算）
		#if tokens[0]["bbcode_tags"].has("extra_duration"):
			# 将extra_duration的值加入动画总时长
			#dialogue_duration += tokens[0]["bbcode_tags"]["extra_duration"]["value"]
			
		# 将单个对话的时间表数据加入dialogue_schedules中
		dialogue_schedules.append(
			{
				"index": dialogues.find(dialogue), # 该对话的位置
				"duration": dialogue_duration, # 该对话的持续时长
				"absolute_start_time": total_duration, # 该对话的绝对开始时间（上一个动画的结束时间）
				"absolute_end_time": total_duration + dialogue_duration - 1 / fps, # 该对话的绝对结束时间（比实际时长少一帧，与下个对话错开）
				"char_schedules": char_schedules # 该对话所包含的字符的时间表
			}
		)
		
		# 将该对话的时长追加至总时长中
		total_duration += dialogue_duration
		
	# 返回值
	return {
		"duration": total_duration, # 动画总时长
		"dialogue_schedules": dialogue_schedules # 动画中所包含的对话的时间表数据
	}
