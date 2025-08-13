extends ItemList

func _ready() -> void:
	# 连接信号
	item_selected.connect(_on_item_selected)
	
	# 初始化选中索引0
	select(0)

## 当选中项变化时执行
func _on_item_selected(index: int):
	# 根据选中项索引判断指定资产类型
	var asset_type: ExternalAssetsManager.AssetType
	
	match index:
		0:
			asset_type = ExternalAssetsManager.AssetType.CHARACTER_FACES
		1:
			asset_type = ExternalAssetsManager.AssetType.CHARACTER_SOUNDS
		2:
			asset_type = ExternalAssetsManager.AssetType.DIALOGUE_TEXTURES
		3:
			asset_type = ExternalAssetsManager.AssetType.FONTS
		4:
			asset_type = ExternalAssetsManager.AssetType.MISC
			
	# 设置selected_asset_type
	AssetsManagerDataManager.selected_asset_type = asset_type
