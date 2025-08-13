extends TextureRect

func _ready() -> void:
	# 连接信号
	AssetsManagerDataManager.selected_key_changed.connect(_update_ui)
	AssetsManagerDataManager.selected_index_changed.connect(_update_ui)

## 更新ui
func _update_ui():
	# 设置纹理
	if AssetsManagerDataManager.selected_key != "" and AssetsManagerDataManager.selected_index != -1 and AssetsManagerDataManager.selected_asset_type == ExternalAssetsManager.AssetType.CHARACTER_FACES:
		texture = AssetLoader.load_asset(ExternalAssetsManager.get_asset_info(AssetsManagerDataManager.selected_asset_type, AssetsManagerDataManager.selected_key, AssetsManagerDataManager.selected_index)["path"])
