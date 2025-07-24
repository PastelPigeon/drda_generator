extends Control

func _ready() -> void:
	## 初始化读取options并更新ui
	var options = UmOptionsConfigManager.get_options()
	
	%FpsInput.value = float(options["fps"])
	%BackgroundInput.color = Color(options["background"])
	%RecordingModeInput.selected = 0 if options["recording_mode"] == "single" else 1
	%RecordingsOutputDirInput.text = options["recordings_output_dir"]
