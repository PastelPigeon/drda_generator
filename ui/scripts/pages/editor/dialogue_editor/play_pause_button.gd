extends Button

func _ready() -> void:
	# 连接信号
	%GeneratorPreview.canplay_state_changed.connect(_on_canplay_state_changed)
	%GeneratorPreview.animation_player_playing_changed.connect(_on_animation_player_playing_changed)
	
	# 默认禁用
	disabled = true
	
func _pressed() -> void:
	# 设置动画播放状态
	%GeneratorPreview.set_animation_player_playing(!%GeneratorPreview.get_animation_player_playing())

## 当能否播放状态改变时执行
func _on_canplay_state_changed():
	# 根据能否播放状态设置是否禁用
	match %GeneratorPreview.get_canplay_state():
		true:
			disabled = false
		false:
			disabled = true
			
## 当动画播放状态改变时执行
func _on_animation_player_playing_changed():
	# 根据动画播放状态设置图标
	match %GeneratorPreview.get_animation_player_playing():
		true:
			icon = load("res://ui/assets/icons/pause.png")
		false:
			icon = load("res://ui/assets/icons/play.png")
