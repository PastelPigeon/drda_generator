extends LineEdit

## 未编辑前的原始文本
var original_text = ""

func _ready() -> void:
	# 连接信号
	editing_toggled.connect(_on_editing_toggled)
	text_submitted.connect(_on_text_submitted)
	AssetsManagerDataManager.selected_key_changed.connect(_update_ui)
	AssetsManagerDataManager.selected_index_changed.connect(_update_ui)

## 当切换编辑状态时执行
func _on_editing_toggled(toggled_on: bool):
	if toggled_on == true:
		original_text = text
		
## 当提交文本时执行
func _on_text_submitted(new_text: String):
	# 判断是否为空文本或不为整数，空文本或不为整数直接返回，还原输入框内容
	if new_text == "" or StringTypesChecker.is_float_string(new_text) == false:
		text = original_text
		return
		
	# 设置资产属性
	ExternalAssetsManager.set_asset_attribute_CHARACTER_SOUNDS(AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index, int(new_text), ExternalAssetsManager.get_asset_info(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index)["random_pitch"])
	
## 更新ui
func _update_ui():
	# 设置文本
	if AssetsManagerDataManager.selected_key != "" and AssetsManagerDataManager.selected_index != -1 and AssetsManagerDataManager.selected_asset_type == ExternalAssetsManager.AssetType.CHARACTER_SOUNDS:
		text = str(ExternalAssetsManager.get_asset_info(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index)["sound_timer"])
