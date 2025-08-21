extends Node

## 动画的所有路径
const TRACK_PATHS = [
	"%s:position" % "Dialogue",
	"%s:dialogue_style" % "Dialogue/DialogueTexture",
	"%s:text_animation_state" % "Dialogue/DialogueTexture",
	#"%s:visible" % "Dialogue/DialogueTextureDark",
	#"%s:visible" % "Dialogue/DialogueTextureLight",
	"%s:texture" % "Dialogue/CharacterFace",
	"%s:visible" % "Dialogue/CharacterFace",
	"%s:position" % "Dialogue/PlaceholderChar",
	"%s:visible" % "Dialogue/PlaceholderChar/Shadow",
	"%s:position" % "Dialogue/Text",
	"%s:size" % "Dialogue/Text",
	"%s:text" % "Dialogue/Text/Text",
	"%s:visible_characters" % "Dialogue/Text/Text",
	"%s:text" % "Dialogue/Text/Shadow",
	"%s:visible_characters" % "Dialogue/Text/Shadow",
	"%s:visible" % "Dialogue/Text/Shadow",
]

## 生成可见动画
func generate_visible_animation(dialogues: Array, options: Dictionary) -> Animation:
	# 计算动画的时间表
	var animation_schedule = AnimationScheduleCalculator.calculate_animation_schedule(dialogues, options["fps"])
	
	# 初始化动画
	var visible_animation = Animation.new()
	visible_animation.loop_mode = Animation.LOOP_NONE
	visible_animation.length = animation_schedule["duration"]
	
	# 创建动画轨道
	for track_path in TRACK_PATHS:
		var track_index = visible_animation.add_track(Animation.TYPE_VALUE)
		visible_animation.track_set_path(track_index, track_path)
		visible_animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
		
	# 遍历dialogues
	for dialogue_index in range(len(dialogues)):
		# 获取dialogue的时间表
		var dialogue_schedule = animation_schedule["dialogue_schedules"][dialogue_index]
		
		# 获取该对话的tokens
		var tokens = BbcodeParser.parse_bbcode_string_to_tokens(dialogues[dialogue_index])
		
		# 遍历tokens，创建关键帧
		for token_index in range(len(tokens)):
			# 获取当前字符的时间表
			var char_schedule = dialogue_schedule["char_schedules"][token_index]
			
			# 获取该字符的可见动画的路径值对
			var path_value_pairs = VisibleAnimationPathValuePairsGenerator.generate_visible_animation_path_value_pairs(tokens[token_index], dialogues[dialogue_index])
			
			# 从获取到的路径值对中打关键帧
			for path in path_value_pairs.keys():
				var track_index = visible_animation.find_track(path, Animation.TYPE_VALUE)
				visible_animation.track_insert_key(track_index, char_schedule["absolute_start_time"], path_value_pairs[path])
				visible_animation.track_insert_key(track_index, char_schedule["absolute_end_time"], path_value_pairs[path])
				
	return visible_animation
