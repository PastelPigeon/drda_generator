extends Button

func _ready() -> void:
	# 连接信号
	AssetsManagerDataManager.selected_key_changed.connect(_update_ui)
	AssetsManagerDataManager.selected_index_changed.connect(_update_ui)
	
	# 手动更新ui
	_update_ui()

## 更新ui
func _update_ui():
	if AssetsManagerDataManager.selected_key != "" and AssetsManagerDataManager.selected_index == -1:
		disabled = false
	else:
		disabled = true
		
func _pressed() -> void:
	# 唤起系统文件对话框
	DisplayServer.file_dialog_show("选择资产文件", "", "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, [], _select_file_handler)
	
## 系统文件对话框回调函数
func _select_file_handler(status:bool, selected_paths:PackedStringArray, _selected_filter_index:int):
	# status为false直接返回
	if status == false:
		return
		
	# 添加资产
	ExternalAssetsManager.add_asset(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, selected_paths[0])
	
	# 手动更新AssetsTree ui
	AssetsManagerDataManager.assets_viewer_assets_tree_updating_needed.emit()
