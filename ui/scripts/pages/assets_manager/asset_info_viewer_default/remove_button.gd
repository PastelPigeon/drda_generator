extends Button

func _pressed() -> void:
	# 删除资产
	ExternalAssetsManager.remove_asset(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index)
	
	# 设置selected_key及selected_index
	AssetsManagerDataManager.selected_key = ""
	AssetsManagerDataManager.selected_index = -1
	
	# 手动更新AssetsTree ui
	AssetsManagerDataManager.assets_viewer_assets_tree_updating_needed.emit()
