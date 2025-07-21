extends Node

## 生成录制控制动画
func generate_recording_animation(dialogues: Array, options: Dictionary) -> Animation:
	# 计算动画的时间表
	var animation_schedule = AnimationScheduleCalculator.calculate_animation_schedule(dialogues, options["fps"])
	
	# 初始化动画
	var recording_animation = Animation.new()
	recording_animation.loop_mode = Animation.LOOP_NONE
	recording_animation.length = animation_schedule["duration"] + 1 / options["fps"] * 2
	
	# 创建录制控制轨道
	var track_index = recording_animation.add_track(Animation.TYPE_METHOD)
	recording_animation.track_set_path(track_index, "/root/RecordingManager")
	
	# 根据不同的录制模式，创建不同的录制控制
	match options["recording_mode"]:
		"multiple":
			# 多录制模式，将不同的对话拆分到不同的视频文件中
			for dialogue_index in range(len(dialogues)):
				# 获取当前对话的时间表
				var dialogue_schedule = animation_schedule["dialogue_schedules"][dialogue_index]
				
				# 开始录制
				recording_animation.track_insert_key(track_index, dialogue_schedule["absolute_start_time"], {
					"method": "start_recording",
					"args": [options["fps"], options["recordings_output_dir"].path_join(DialogueBbcodeTagsCleaner.clean_bbcode_tags_from_dialogue(dialogues[dialogue_index]))]
				})
				
				# 结束录制
				recording_animation.track_insert_key(track_index, dialogue_schedule["absolute_end_time"], {
					"method": "stop_recording",
					"args": []
				})
		"single":
			# 单录制模式，所有对话录制到单个视频文件中
			
			# 开始录制
			recording_animation.track_insert_key(track_index, 0, {
				"method": "start_recording",
				"args": [options["fps"], options["recordings_output_dir"].path_join("对话")]
			})
			
			# 结束录制
			recording_animation.track_insert_key(track_index, animation_schedule["duration"], {
				"method": "stop_recording",
				"args": []
			})
			
	# 设置录制输出位置
	recording_animation.track_insert_key(track_index, animation_schedule["duration"] + (1 / options["fps"]) * 1, {
		"method": "set_output_dir",
		"args": [options["recordings_output_dir"]]
	})
	
	# 输出录制
	recording_animation.track_insert_key(track_index, animation_schedule["duration"] + (1 / options["fps"]) * 2, {
		"method": "save_all_recordings",
		"args": []
	})
	
	return recording_animation
