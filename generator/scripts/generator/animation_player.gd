extends AnimationPlayer

func _ready() -> void:
	owner.properties_changed.connect(_on_properties_changed)

func _on_properties_changed():
	if len(owner.dialogues) != 0 and owner.options.has("fps") and owner.options.has("recording_mode") and owner.options.has("recordings_output_dir"):
		# 生成对话动画
		var dialogues_animation = AnimationGenerator.generate_animation(owner.dialogues, owner.options)
		
		# 将动画添加到动画库中
		var dialogues_animation_library = AnimationLibrary.new()
		dialogues_animation_library.add_animation("dialogues_animation", dialogues_animation)
		
		# 将动画库添加到自己的动画中
		add_animation_library("dialogues_animation_library", dialogues_animation_library)
		
		# 播放动画
		play("dialogues_animation_library/dialogues_animation")
		
		# 存储生成出来的动画（debug）
		# ResourceSaver.save(dialogues_animation_library, "res://anim.tres")
