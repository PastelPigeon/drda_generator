extends Node

## 生成选项动画
func generate_options_animation(dialogues: Array, options: Dictionary) -> Animation:
	# 计算动画时间表
	var animation_schedule = AnimationScheduleCalculator.calculate_animation_schedule(dialogues, options["fps"])
	
	# 初始化选项对话
	var options_animation = Animation.new()
	options_animation.loop_mode = Animation.LOOP_NONE
	options_animation.length = animation_schedule["duration"]
	
	# 初始化动画轨道
	var visible_track_index = options_animation.add_track(Animation.TYPE_METHOD)
	options_animation.track_set_path(visible_track_index, "Dialogue/OptionItemsContainer")
	
	var audio_track_index = options_animation.add_track(Animation.TYPE_AUDIO)
	options_animation.track_set_path(audio_track_index, "AudioStreamPlayer")
	
	# 遍历dialogues
	for dialogue_index in range(len(dialogues)):
		# 获取对话时间表
		var dialogue_schedule = animation_schedule["dialogue_schedules"][dialogue_index]
		
		# 获取tokens
		var tokens = BbcodeParser.parse_bbcode_string_to_tokens(dialogues[dialogue_index])
		
		# 遍历tokens
		for token_index in range(len(tokens)):
			# 判断当前token是否为options自闭合控制标签，不是直接跳过
			if tokens[token_index]["bbcode_tags"].has("options") == false:
				continue
				
			# 获取字符时间表
			var char_schedule = dialogue_schedule["char_schedules"][token_index]
			
			# 控制OptionItemsContainer可见性
			options_animation.track_insert_key(visible_track_index, char_schedule["absolute_start_time"] + 1 / options["fps"], {
				"method": "show",
				"args": []
			})
			
			options_animation.track_insert_key(visible_track_index, char_schedule["absolute_end_time"], {
				"method": "hide",
				"args": []
			})
			
			# 将options加载到OptionItemsContainer
			options_animation.track_insert_key(visible_track_index, char_schedule["absolute_start_time"], {
				"method": "load_options",
				"args": [tokens[token_index]["bbcode_tags"]["options"]["options"]]
			})
			
			# 遍历actions
			for action_index in range(len(tokens[token_index]["bbcode_tags"]["options"]["actions"])):
				# 获取动作参数
				var delay = float(tokens[token_index]["bbcode_tags"]["options"]["actions"][action_index].split("|")[0])
				var option_index = float(tokens[token_index]["bbcode_tags"]["options"]["actions"][action_index].split("|")[1])
				
				# 获取动作绝对时间
				var absolute_action_time = tokens[token_index]["bbcode_tags"]["options"]["actions"].slice(0, action_index + 1).map(func (action): return float(action.split("|")[0])).reduce(func (a, num): return a + num)
				
				# 根据option_index判断动作类型
				if option_index != -2:
					# 当option_index不为-2时，动作类型为选择
					options_animation.track_insert_key(visible_track_index, absolute_action_time, {
						"method": "select_option",
						"args": [option_index]
					})
					
					options_animation.audio_track_insert_key(audio_track_index, absolute_action_time, AssetLoader.load_asset(AssetFinder.find_asset(AssetFinder.AssetType.MISC, "options_select_sound")[0]))
				else:
					# 当option_index为-2时，动作类型为确认
					options_animation.track_insert_key(visible_track_index, absolute_action_time, {
						"method": "hide",
						"args": []
					})
					
					options_animation.audio_track_insert_key(audio_track_index, absolute_action_time, AssetLoader.load_asset(AssetFinder.find_asset(AssetFinder.AssetType.MISC, "options_confirm_sound")[0]))
					
	return options_animation
