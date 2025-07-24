extends Node

## 所有option键名
enum Option {
	FPS,
	BACKGROUND,
	RECORDING_MODE,
	RECORDINGS_OUTPUT_DIR
}

## options存储文件位置
const OPTIONS_CONFIG_FILE_PATH = "user://options.json"

## 默认选项
var DEFAULT_OPTIONS = {
	"fps": 24.0,
	"background": "green",
	"recording_mode": "single",
	"recordings_output_dir": OS.get_system_dir(OS.SYSTEM_DIR_MOVIES)
}

## 读取选项
func get_options() -> Dictionary:
	# 判断存储文件是否存在
	if FileAccess.file_exists(OPTIONS_CONFIG_FILE_PATH):
		# 存在返回存储文件内容
		var options_file = FileAccess.open(OPTIONS_CONFIG_FILE_PATH, FileAccess.READ)
		var options = JSON.parse_string(options_file.get_as_text())
		options_file.close()
		
		return options
	else:
		# 不存在返回默认值
		return DEFAULT_OPTIONS
		
## 修改选项
func set_option(option: Option, value: Variant):
	# 判断存储文件是否存在
	if FileAccess.file_exists(OPTIONS_CONFIG_FILE_PATH) == false:
		# 如果不存在，先创建存储文件并写入默认值
		var options_file = FileAccess.open(OPTIONS_CONFIG_FILE_PATH, FileAccess.WRITE)
		options_file.store_string(JSON.stringify(DEFAULT_OPTIONS))
		options_file.close()
		
	# 根据option参数获取键名
	var option_key_name = ""
	
	match option:
		Option.FPS:
			option_key_name = "fps"
		Option.BACKGROUND:
			option_key_name = "background"
		Option.RECORDING_MODE:
			option_key_name = "recording_mode"
		Option.RECORDINGS_OUTPUT_DIR:
			option_key_name = "recordings_output_dir"
			
	# 获取现有配置
	var options = get_options()
	
	# 修改配置
	options[option_key_name] = value
	
	# 重新写入存储文件
	var options_file = FileAccess.open(OPTIONS_CONFIG_FILE_PATH, FileAccess.WRITE)
	options_file.store_string(JSON.stringify(options))
	options_file.close()
