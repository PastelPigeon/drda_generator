extends LineEdit

# 选项键名
const KEY_ENUM = OptionsConfigManager.Option.RECORDINGS_OUTPUT_DIR ## enum形式键名
const KEY_STRING = "recordings_output_dir" ## string形式键名

func _ready() -> void:
	# 绑定信号
	text_changed.connect(_update_cv)
	
	# 初始化更新ui值
	_update_uv()

## 将ui值转为存储值
func _convert_uv_to_cv(value: Variant):
	return value

## 将存储值转为ui值
func _convert_cv_to_uv(value: Variant):
	return value
	
## 更新存储值
func _update_cv(new_value: Variant):
	OptionsConfigManager.set_option(KEY_ENUM, _convert_uv_to_cv(new_value))
	
## 更新ui值
func _update_uv():
	text = _convert_cv_to_uv(OptionsConfigManager.get_options()[KEY_STRING])
