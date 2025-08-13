extends Tree

func _ready() -> void:
	# 连接选中信号
	item_selected.connect(_on_item_selected)
	
	# 连接ui更新信号
	AssetsManagerDataManager.selected_asset_type_changed.connect(_update_ui)
	AssetsManagerDataManager.assets_viewer_assets_tree_updating_needed.connect(_update_ui)
	
	# 手动更新一次ui
	_update_ui()

## 当项选中时执行
func _on_item_selected():
	# 获取选中项
	var selected_item = get_selected()
	
	# 设置selected_key与selected_index
	AssetsManagerDataManager.selected_key = selected_item.get_metadata(0)["key"]
	AssetsManagerDataManager.selected_index = selected_item.get_metadata(0)["index"]
	
## 更新ui
func _update_ui():
	# 删除所有项
	clear()
	
	# 获取指定注册表
	var registry = ExternalAssetsManager.get_registry(AssetsManagerDataManager.selected_asset_type)
	
	# 创建根项
	var root_item = create_item()
	root_item.set_text(0, "资产")
	root_item.set_metadata(0, {"key": "", "index": -1})
	
	# 遍历注册表，创建项
	for key_index in range(len(registry.keys())):
		# 创建键项
		var key_item = create_item(root_item)
		key_item.set_text(0, registry.keys()[key_index])
		key_item.set_icon(0, load("res://ui/assets/icons/notepad.png"))
		key_item.set_icon_max_width(0, 16)
		key_item.set_metadata(0, {"key": registry.keys()[key_index], "index": -1})
		
		# 遍历值，创建项
		for asset_index in range(len(registry[registry.keys()[key_index]])):
			# 创建资产项
			var asset_item = create_item(key_item)
			asset_item.set_text(0, ExternalAssetsManager.get_asset_info(AssetsManagerDataManager.selected_asset_type, registry.keys()[key_index], asset_index)["name"])
			asset_item.set_icon(0, load("res://ui/assets/icons/message_file-1.png"))
			asset_item.set_icon_max_width(0, 16)
			asset_item.set_metadata(0, {"key": registry.keys()[key_index], "index": asset_index})
