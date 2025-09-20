extends Button

func _ready() -> void:
	# 连接信号
	%GeneratorPreview.canplay_state_changed.connect(_on_canplay_state_changed)
	
	# 默认禁用
	disabled = true
	
func _pressed() -> void:
	# 设置动画播放时长
	%GeneratorPreview.next_frame()

## 当能否播放状态改变时执行
func _on_canplay_state_changed():
	# 根据能否播放状态设置是否禁用
	match %GeneratorPreview.get_canplay_state():
		true:
			disabled = false
		false:
			disabled = true
