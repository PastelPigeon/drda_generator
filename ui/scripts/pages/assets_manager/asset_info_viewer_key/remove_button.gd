extends Button

func _pressed() -> void:
	# 移除键
	ExternalAssetsManager.remove_key(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key)
	
	# 设置selected_key
	AssetsManagerDataManager.selected_key = ""
	
	# 手动更新AssetsTree ui
	AssetsManagerDataManager.assets_viewer_assets_tree_updating_needed.emit()
