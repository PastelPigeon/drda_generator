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
			
			var sound_stream = null
			
			# 获取当前字符的对话音效资源
			if tokens[token_index]["bbcode_tags"].has("sound"):
				sound_stream = load(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, tokens[token_index]["bbcode_tags"]["sound"]["value"])[randi_range(0, len(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, tokens[token_index]["bbcode_tags"]["sound"]["value"])) - 1)])
			else:
				sound_stream = load(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, "default")[0])
				
			# 获取上一音频关键帧的index
			var last_audio_key_index = audio_animation.track_find_key(track_index, char_schedule["absolute_start_time"], Animation.FIND_MODE_NEAREST)
			
			# 获取上一音频关键帧的stream的结束时间（当没有上一关键帧时，结束时间为0）
			var last_audio_key_end_time = 0
			
			if last_audio_key_index != -1:
				# 计算方式：上一音频关键帧的时间 + 上一音频关键帧的stream的时长
				last_audio_key_end_time = audio_animation.track_get_key_time(track_index, last_audio_key_index) + audio_animation.audio_track_get_key_stream(track_index, last_audio_key_index).get_length()
				
			# 判断当前字符绝对时间是否与上一音频关键帧的播放时间重叠，如果重叠，跳过该字符，不添加关键帧
			if char_schedule["absolute_start_time"] <= last_audio_key_end_time:
				continue
				
			# 根据当前字符时间与上个音频stream结束时间差来判断添加行为
			if char_schedule["absolute_start_time"] - last_audio_key_end_time <= 1 / options["fps"]:
				# 当时间差不满一帧时，将音频添加到上个音频流末尾位置
				audio_animation.audio_track_insert_key(track_index, last_audio_key_end_time, sound_stream)
			else:
				# 当时间差超过一帧时，将音频流添加到字符绝对开始时间
				audio_animation.audio_track_insert_key(track_index, char_schedule["absolute_start_time"], sound_stream)
			
	return audio_animation
