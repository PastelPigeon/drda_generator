extends Button

func _pressed() -> void:
	# 当点击按钮时播放指定音频流
	if AssetsManagerDataManager.selected_key != "" and AssetsManagerDataManager.selected_index != -1 and AssetsManagerDataManager.selected_asset_type == ExternalAssetsManager.AssetType.CHARACTER_SOUNDS:
		%AudioStreamPlayer.stream = AssetLoader.load_asset(ExternalAssetsManager.get_asset_info(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index)["path"])
		%AudioStreamPlayer.play()
