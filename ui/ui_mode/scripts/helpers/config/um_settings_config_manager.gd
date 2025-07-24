extends Node

## 所有setting键名
enum Setting {
	THEME
}

## settings存储文件位置
const SETTINGS_CONFIG_FILE_PATH = "user://settings.json"

## 默认设置
const DEFAULT_SETTINGS = {
	"theme": "kris"
}

## 读取设置
func get_settings() -> Dictionary:
	# 判断存储文件是否存在
	if FileAccess.file_exists(SETTINGS_CONFIG_FILE_PATH):
		# 存在返回存储文件中的内容
		var settings_file = FileAccess.open(SETTINGS_CONFIG_FILE_PATH, FileAccess.READ)
		var settings = JSON.parse_string(settings_file.get_as_text())
		settings_file.close()
		
		return settings
	else:
		# 不存在返回默认设置
		return DEFAULT_SETTINGS
		
## 修改设置
func set_setting(setting: Setting, value: Variant):
	# 判断设置存储文件是否存在
	if FileAccess.file_exists(SETTINGS_CONFIG_FILE_PATH) == false:
		# 不存在创建并写入默认值
		var settings_file = FileAccess.open(SETTINGS_CONFIG_FILE_PATH, FileAccess.WRITE)
		settings_file.store_string(JSON.stringify(DEFAULT_SETTINGS))
		settings_file.close()
		
	# 根据setting参数获取键名
	var setting_key_name = ""
	
	match setting:
		Setting.THEME:
			setting_key_name = "theme"
			
	# 获取现有设置
	var settings = get_settings()
	
	# 修改设置
	settings[setting_key_name] = value
	
	# 重新写入配置存储文件
	var settings_file = FileAccess.open(SETTINGS_CONFIG_FILE_PATH, FileAccess.WRITE)
	settings_file.store_string(JSON.stringify(settings))
	settings_file.close()
