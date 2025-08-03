extends OptionButton

# 选项键名
const KEY_ENUM = OptionsConfigManager.Option.RECORDING_ENABLE_TRANSPARENT ## enum形式键名
const KEY_STRING = "recording_enable_transparent" ## string形式键名

func _ready() -> void:
	# 绑定信号
	item_selected.connect(_update_cv)
	
	# 初始化更新ui值
	_update_uv()
	
func _process(delta: float) -> void:
	# 根据RecordingFormatInput节点的内容确认该节点是否启用
	if %RecordingFormatInput.selected == 0:
		# 当选中mp4时禁用该节点
		disabled = true
		
		# 如果禁用前选择了启用，手动设为禁用并更新存储中的值
		if selected == 1:
			selected = 0
			OptionsConfigManager.set_option(KEY_ENUM, false)
	else:
		# 当选中非mp4时启用该节点
		disabled = false

## 将ui值转为存储值
func _convert_uv_to_cv(value: Variant):
	return false if value == 0 else true

## 将存储值转为ui值
func _convert_cv_to_uv(value: Variant):
	return 0 if value == false else 1
	
## 更新存储值
func _update_cv(new_value: Variant):
	OptionsConfigManager.set_option(KEY_ENUM, _convert_uv_to_cv(new_value))
	
## 更新ui值
func _update_uv():
	selected = _convert_cv_to_uv(OptionsConfigManager.get_options()[KEY_STRING])
