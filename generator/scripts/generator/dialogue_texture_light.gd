extends TextureRect

func _ready() -> void:
	texture = load(AssetFinder.find_asset(AssetFinder.AssetType.DIALOGUE_TEXTURES, "light")[0])
