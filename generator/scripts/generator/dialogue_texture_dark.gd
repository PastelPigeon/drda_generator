extends TextureRect

var _next_texture_delay = 0.3
var _time_to_next_texture = 0
var _current_texture_index = 0

func _process(delta: float) -> void:
	if _time_to_next_texture <= 0:
		texture = load(AssetFinder.find_asset(AssetFinder.AssetType.DIALOGUE_TEXTURES, "dark")[_current_texture_index])
		
		if _current_texture_index == len(AssetFinder.find_asset(AssetFinder.AssetType.DIALOGUE_TEXTURES, "dark")) - 1:
			_current_texture_index = 0
		else:
			_current_texture_index += 1
		
		_time_to_next_texture = _next_texture_delay
	else:
		_time_to_next_texture -= delta
