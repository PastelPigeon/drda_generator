extends Node

## 需要跳过生成音效的字符（半角+全角）
const SKIPPED_CHARS = [
	" ",
	"^",
	"!",
	".",
	"?",
	",",
	":",
	"/",
	"\\",
	"|",
	"*",
	"！",
	"。",
	"？",
	"，",
	"："
]

## 生成音频动画
func generate_audio_animation(dialogues: Array, options: Dictionary) -> Animation:
	# 计算动画的时间表
	var animation_schedule = AnimationScheduleCalculator.calculate_animation_schedule(dialogues, options["fps"])
	
	# 初始化音频动画
	var audio_animation = Animation.new()
	audio_animation.loop_mode = Animation.LOOP_NONE
	audio_animation.length = animation_schedule["duration"]
	
	# 初始化音频轨道
	var track_index = audio_animation.add_track(Animation.TYPE_AUDIO)
	audio_animation.track_set_path(track_index, "AudioStreamPlayer")
	
	# 遍历dialogues
	for dialogue_index in range(len(dialogues)):
		# 获取对话时间表
		var dialogue_schedule = animation_schedule["dialogue_schedules"][dialogue_index]
		
		# 获取对话tokens
		var tokens = BbcodeParser.parse_bbcode_string_to_tokens(dialogues[dialogue_index])
		
		# 初始化sound_timer
		var sound_timer = 0
		
		# 遍历tokens
		for token_index in range(len(tokens)):
			# 获取字符时间表
			var char_schedule = dialogue_schedule["char_schedules"][token_index]
			
			# 将sound_timer减去该字符和上个字符的时间差（以帧为单位）
			if token_index != 0:
				sound_timer -= (dialogue_schedule["char_schedules"][token_index]["absolute_start_time"] - dialogue_schedule["char_schedules"][token_index - 1]["absolute_start_time"]) * options["fps"]
			else:
				sound_timer -= 0
				
			# 判断该字符是否为自闭合标签，是直接跳过
			if tokens[token_index]["char"] == "":
				continue
				
			# 判断该字符是否在SKIPPED_CHARS当中，在直接跳过
			if SKIPPED_CHARS.has(tokens[token_index]["char"]):
				continue
				
			# sound_timer大于0时直接跳过该字符
			if sound_timer > 0:
				continue
				
			# 获取对话音效资源路径（当没有sound标签时，使用默认对话音效default）
			var asset_path = AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, "default")[0]
			
			# 当有sound标签时，获取指定对话音效的资源路径
			if tokens[token_index]["bbcode_tags"].has("sound"):
				# 获取指定对话音效资源路径（随机音效）
				asset_path = AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, tokens[token_index]["bbcode_tags"]["sound"]["value"])[randi_range(0, len(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_SOUNDS, tokens[token_index]["bbcode_tags"]["sound"]["value"])) - 1)]
				
			# 设置sound_timer（根据资源文件名中的@x-x设置）
			sound_timer = float(asset_path.get_file().replace(".%s" % asset_path.get_extension(), "").split("@")[1].split("-")[0])
			
			# 初始化AudioStreamRandomizer
			var sound_stream = AudioStreamRandomizer.new()
			
			# 将对话音效stream添加到AudioStreamRandomizer
			sound_stream.add_stream(0, load(asset_path))
			
			# 设置随机程度（根据资源文件名中的@x-x设置）
			sound_stream.random_pitch = float(asset_path.get_file().replace(".%s" % asset_path.get_extension(), "").split("@")[1].split("-")[1])
			
			# 将sound_stream添加到animation中（时间为该字符的absolute_start_time）
			audio_animation.audio_track_insert_key(track_index, char_schedule["absolute_start_time"], sound_stream)
			
	return audio_animation
