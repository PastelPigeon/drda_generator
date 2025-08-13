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
	# 判断是否为空文本，空文本直接返回，还原输入框内容
	if new_text == "":
		text = original_text
		return
		
	# 重命名键
	ExternalAssetsManager.rename_key(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, new_text)
	
	# 设置selected_key
	AssetsManagerDataManager.selected_key = new_text
	
	# 手动更新AssetsTree ui
	AssetsManagerDataManager.assets_viewer_assets_tree_updating_needed.emit()
	
## 更新ui
func _update_ui():
	# 设置文本
	text = AssetsManagerDataManager.selected_key
