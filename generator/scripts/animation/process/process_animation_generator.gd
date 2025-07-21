extends Node

## 生成进程控制动画
func generate_process_animation(dialogues: Array, options: Dictionary) -> Animation:
	# 计算动画时间表
	var animation_schedule = AnimationScheduleCalculator.calculate_animation_schedule(dialogues, options["fps"])
	
	# 初始化动画
	var process_animation = Animation.new()
	process_animation.loop_mode = Animation.LOOP_NONE
	# 将动画时长延长5帧，确保有足够的清理时间
	process_animation.length = animation_schedule["duration"] + 1 / options["fps"] * 5
	
	# 初始化进程控制轨道
	var track_index = process_animation.add_track(Animation.TYPE_METHOD)
	process_animation.track_set_path(track_index, "/root/ProcessManager")
	
	# 添加进程结束关键帧（动画结束后的5帧后）
	process_animation.track_insert_key(track_index, animation_schedule["duration"] + 1 / options["fps"] * 5, {
		"method": "end_process",
		"args": []
	})
	
	return process_animation
