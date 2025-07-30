extends OptionButton

# 选项键名
const KEY_ENUM = OptionsConfigManager.Option.RECORDING_FORMAT ## enum形式键名
const KEY_STRING = "recording_format" ## string形式键名

func _ready() -> void:
	# 绑定信号
	item_selected.connect(_update_cv)
	
	# 初始化更新ui值
	_update_uv()

## 将ui值转为存储值
func _convert_uv_to_cv(value: Variant):
	return "mp4" if value == 0 else "mov" if value == 1 else "gif"

## 将存储值转为ui值
func _convert_cv_to_uv(value: Variant):
	return 0 if value == "mp4" else 1 if value == "mov" else 2
	
## 更新存储值
func _update_cv(new_value: Variant):
	OptionsConfigManager.set_option(KEY_ENUM, _convert_uv_to_cv(new_value))
	
## 更新ui值
func _update_uv():
	selected = _convert_cv_to_uv(OptionsConfigManager.get_options()[KEY_STRING])
