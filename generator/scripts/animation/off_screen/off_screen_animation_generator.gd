extends Node

## 生成小对话框控制动画
func generate_off_screen_animation(dialogues: Array, options: Dictionary) -> Animation:
	# 计算动画时间表
	var animation_schedule = AnimationScheduleCalculator.calculate_animation_schedule(dialogues, options["fps"])
	
	# 初始化动画
	var off_screen_animation = Animation.new()
	off_screen_animation.loop_mode = Animation.LOOP_NONE
	off_screen_animation.length = animation_schedule["duration"]
	
	# 创建轨道
	var track_index = off_screen_animation.add_track(Animation.TYPE_METHOD)
	off_screen_animation.track_set_path(track_index, "Dialogue/OffScreenItemsContainer")
	
	# 遍历对话
	for dialogue_index in range(len(dialogues)):
		# 获取当前对话时间表
		var dialogue_schedule = animation_schedule["dialogue_schedules"][dialogue_index]
		
		# 获取当前对话的tokens
		var tokens = BbcodeParser.parse_bbcode_string_to_tokens(dialogues[dialogue_index])
		
		# 遍历tokens
		for token_index in range(len(tokens)):
			# 判断是否为off_screen小对话框标签，不是直接跳过
			if tokens[token_index]["bbcode_tags"].has("off_screen") == false:
				continue
				
			# 获取当前字符的时间表
			var char_schedule = dialogue_schedule["char_schedules"][token_index]
			
			# 获取小对话框唯一名称
			var off_screen_item_name = "OffScreenItem_%s_%s" % [dialogue_index, token_index]
			
			# 创建小对话框
			off_screen_animation.track_insert_key(track_index, char_schedule["absolute_start_time"] - 1 / options["fps"], {
				"method": "add_item",
				"args": [off_screen_item_name, tokens[token_index]["bbcode_tags"]["off_screen"]["face"], tokens[token_index]["bbcode_tags"]["off_screen"]["text"]]
			})
			
			# 播放小对话框出现动画
			off_screen_animation.track_insert_key(track_index, char_schedule["absolute_start_time"], {
				"method": "play_item_anim",
				"args": [off_screen_item_name, 0.5]
			})
			
			# 删除小对话框
			off_screen_animation.track_insert_key(track_index, dialogue_schedule["absolute_end_time"], {
				"method": "remove_item",
				"args": [off_screen_item_name]
			})
			
	return off_screen_animation
