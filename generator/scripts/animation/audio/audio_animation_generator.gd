extends Node

## 生成音频动画
func generate_audio_animation(dialogues: Array, options: Dictionary) -> Animation:
	# 计算动画的时间表
	var animation_schedule = AnimationScheduleCalculator.calculate_animation_schedule(dialogues, options["fps"])
	
	# 初始化动画
	var audio_animation = Animation.new()
	audio_animation.loop_mode = Animation.LOOP_NONE
	audio_animation.length = animation_schedule["duration"]
	
	# 创建动画路径
	var track_index = audio_animation.add_track(Animation.TYPE_AUDIO)
	audio_animation.track_set_path(track_index, "AudioStreamPlayer")
	
	# 遍历dialogues
	for dialogue_index in range(len(dialogues)):
		# 获取当前对话的时间表
		var dialogue_schedule = animation_schedule["dialogue_schedules"][dialogue_index]
		
		# 获取当前对话的tokens
		var tokens = BbcodeParser.parse_bbcode_string_to_tokens(dialogues[dialogue_index])
		
		# 遍历tokens
		for token_index in range(len(tokens)):
			# 获取当前字符的时间表
			var char_schedule = dialogue_schedule["char_schedules"][token_index]
			
			# 当包含disable_sound控制标签时跳过该字符
			if tokens[token_index]["bbcode_tags"].has("disable_sound"):
				continue
			
			# 如果当前帧有音频播放，则跳过
			var last_audio_key_index = audio_animation.track_find_key(track_index, char_schedule["absolute_start_time"], Animation.FIND_MODE_NEAREST)
			if last_audio_key_index != -1:
				var last_audio_key_end_time = audio_animation.track_get_key_time(track_index, last_audio_key_index) + audio_animation.audio_track_get_key_stream(track_index, last_audio_key_index).get_length()
				
				# 当前帧的时间处于上个音频帧的播放时间内，跳过(位于上个音频播放时间内但上个音频时长已不满一帧，不跳过)
				if char_schedule["absolute_start_time"] <= last_audio_key_end_time and last_audio_key_end_time - char_schedule["absolute_start_time"] >= 1 / options["fps"]:
					continue
			
			var sound_stream = null
			
			# 获取当前字符的对话音效资源
			if tokens[token_index]["bbcode_tags"].has("sound"):
				sound_stream = load(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, tokens[token_index]["bbcode_tags"]["sound"]["value"])[randi_range(0, len(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, tokens[token_index]["bbcode_tags"]["sound"]["value"])) - 1)])
			else:
				sound_stream = load(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, "default")[0])
				
			audio_animation.audio_track_insert_key(track_index, char_schedule["absolute_start_time"], sound_stream)
			
	return audio_animation
