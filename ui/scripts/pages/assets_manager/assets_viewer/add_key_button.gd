extends Button

## 键基本名称
const KEY_NAME_BASE = "新建键"

func _pressed() -> void:
	# 获取指定注册表
	var registry = ExternalAssetsManager.get_registry(AssetsManagerDataManager.selected_asset_type)
	
	# 获取键唯一名称
	var key_unique_name_id = 0
	
	while true:
		if registry.keys().has("%s_%s" % [KEY_NAME_BASE, str(key_unique_name_id)] if key_unique_name_id != 0 else KEY_NAME_BASE) == false:
			break
			
		key_unique_name_id += 1
		
	var key_unique_name = "%s_%s" % [KEY_NAME_BASE, str(key_unique_name_id)] if key_unique_name_id != 0 else KEY_NAME_BASE
	
	# 添加键
	ExternalAssetsManager.add_key(AssetsManagerDataManager.selected_asset_type, key_unique_name)
	
	# 手动更新AssetsTree ui
	AssetsManagerDataManager.assets_viewer_assets_tree_updating_needed.emit()
