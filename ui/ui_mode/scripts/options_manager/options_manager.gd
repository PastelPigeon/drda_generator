extends Control

func _ready() -> void:
	## 初始化读取options并更新ui
	var options = UmOptionsConfigManager.get_options()
	
	%FpsInput.value = float(options["fps"])
	%BackgroundInput.color = Color(options["background"])
	%RecordingModeInput.selected = 0 if options["recording_mode"] == "single" else 1
	%RecordingsOutputDirInput.text = options["recordings_output_dir"]
	%RecordingFormatInput.selected = 0 if options["recording_format"] == "mp4" else 1 if options["recording_format"] == "mov" else 2
	%RecordingEnableTransparentInput.selected = 0 if options["recording_enable_transparent"] == false else 1

	# 如果选择格式为mp4，处理RecordingEnableTransparentInput
	if %RecordingFormatInput.selected == 0:
		# 强制将RecordingEnableTransparentInput的值设为禁用
		%RecordingEnableTransparentInput.selected = 0
		
		# 手动更新存储
		UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.RECORDING_ENABLE_TRANSPARENT, false)
		
		# 禁用RecordingEnableTransparentInput
		%RecordingEnableTransparentInput.disabled = true
