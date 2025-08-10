extends TextureRect

func _ready() -> void:
	# 动态加载灵魂纹理
	texture = AssetLoader.load_asset(AssetFinder.find_asset(AssetFinder.AssetType.MISC, "soul")[0])
