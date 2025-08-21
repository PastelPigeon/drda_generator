extends OptionButton

## 未编辑前的原始文本
var original_text = ""

func _ready() -> void:
	# 连接信号
	#editing_toggled.connect(_on_editing_toggled)
	item_selected.connect(_on_item_selected)
	AssetsManagerDataManager.selected_key_changed.connect(_update_ui)
	AssetsManagerDataManager.selected_index_changed.connect(_update_ui)

## 当切换编辑状态时执行
func _on_editing_toggled(toggled_on: bool):
	pass
		
## 当选中项
func _on_item_selected(index: int):
	# 设置资产属性
	ExternalAssetsManager.set_asset_attribute_DIALOGUE_TEXTURES(AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index, ExternalAssetsManager.get_asset_info(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index)["next_texture_timer"], "playing" if index == 0 else "ended" if index == 1 else "all")
	
## 更新ui
func _update_ui():
	# 选中项
	if AssetsManagerDataManager.selected_key != "" and AssetsManagerDataManager.selected_index != -1:
		var text_animation_state = ExternalAssetsManager.get_asset_info(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index)["text_animation_state"]
		select(0 if text_animation_state == "playing" else 1 if text_animation_state == "ended" else 2)
