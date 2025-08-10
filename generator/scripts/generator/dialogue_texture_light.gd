extends TextureRect

func _ready() -> void:
	texture = AssetLoader.load_asset(AssetFinder.find_asset(AssetFinder.AssetType.DIALOGUE_TEXTURES, "light")[0])
