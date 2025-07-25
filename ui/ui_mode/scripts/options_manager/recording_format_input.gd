extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_item_selected)

func _on_item_selected(_selected: int):
	# 存储选项
	UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.RECORDING_FORMAT, "mp4" if selected == 0 else "mov" if selected == 1 else "gif")
	
	# 处理RecordingEnableTransparentInput
	if selected == 0:
		# 强制将RecordingEnableTransparentInput的值设为禁用
		%RecordingEnableTransparentInput.selected = 0
		
		# 手动更新存储
		UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.RECORDING_ENABLE_TRANSPARENT, false)
		
		# 禁用RecordingEnableTransparentInput
		%RecordingEnableTransparentInput.disabled = true
	else:
		# 启用RecordingEnableTransparentInput
		%RecordingEnableTransparentInput.disabled = false
	
