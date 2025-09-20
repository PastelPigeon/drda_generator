extends Node

## 生成对话框动画
func generate_animation(dialogues: Array, options: Dictionary) -> Animation:
	var visible_animation = VisibleAnimationGenerator.generate_visible_animation(dialogues, options)
	var audio_animation = AudioAnimationGenerator.generate_audio_animation(dialogues, options)
	var recording_animation = RecordingAnimationGenerator.generate_recording_animation(dialogues, options)
	var process_animation = ProcessAnimationGenerator.generate_process_animation(dialogues, options)
	var off_screen_animation = OffScreenAnimationGenerator.generate_off_screen_animation(dialogues, options)
	var options_animation = OptionsAnimationGenerator.generate_options_animation(dialogues, options)
	
	return AnimationMerger.merge_animations(
		[
			visible_animation,
			audio_animation,
			recording_animation,
			process_animation,
			off_screen_animation,
			options_animation
		],
		options["fps"]
	)
	
## 生成对话框动画（预览）
func generate_animation_preview(dialogues: Array, options: Dictionary) -> Animation:
	var visible_animation = VisibleAnimationGenerator.generate_visible_animation(dialogues, options)
	var audio_animation = AudioAnimationGenerator.generate_audio_animation(dialogues, options)
	var off_screen_animation = OffScreenAnimationGenerator.generate_off_screen_animation(dialogues, options)
	var options_animation = OptionsAnimationGenerator.generate_options_animation(dialogues, options)
	
	return AnimationMerger.merge_animations(
		[
			visible_animation,
			audio_animation,
			off_screen_animation,
			options_animation
		],
		options["fps"]
	)
