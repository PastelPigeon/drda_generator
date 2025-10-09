extends Node

## 生成可见动画的动画值
func generate_visible_animation_path_value_pairs(token: Dictionary, dialogue: String) -> Dictionary:
	var dialogue_pvp = _generate_animation_path_value_pairs_dialogue(token)
	var dialoguetexture_pvp = _generate_animation_path_value_pairs_dialoguetexture(token, dialogue)
	var dialoguetexturedark_pvp = _generate_animation_path_value_pairs_dialoguetexturedark(token)
	var dialoguetexturelight_pvp = _generate_animation_path_value_pairs_dialoguetexturelight(token)
	var characterface_pvp = _generate_animation_path_value_pairs_characterface(token)
	var placeholderchar_pvp = _generate_animation_path_value_pairs_placeholderchar(token)
	var placeholderchar_shadow_pvp = _generate_animation_path_value_pairs_placeholderchar_shadow(token)
	var text_pvp = _generate_animation_path_value_pairs_text(token)
	var text_text_pvp = _generate_animation_path_value_pairs_text_text(token, dialogue)
	var text_shadow_pvp = _generate_animation_path_value_pairs_text_shadow(token, dialogue)
	
	return DictionaryMerger.merge_dictionaries([
		dialogue_pvp,
		dialoguetexture_pvp,
		#dialoguetexturedark_pvp,
		#dialoguetexturelight_pvp,
		characterface_pvp,
		placeholderchar_pvp,
		placeholderchar_shadow_pvp,
		text_pvp,
		text_text_pvp,
		text_shadow_pvp
	])

## 生成Dialogue节点的动画值
func _generate_animation_path_value_pairs_dialogue(token: Dictionary) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue"
	
	# 属性路径
	const POSITION_PATH = "%s:position" % NODE_PATH
	
	# 可能的属性值
	var position_value_top = Vector2(49, 6)
	var position_value_bottom = Vector2(49, 622)
	
	# 初始化最终属性
	var position_value = null
	
	# 判断position属性的值
	if token["bbcode_tags"].has("dialogue_display_mode"):
		match token["bbcode_tags"]["dialogue_display_mode"]:
			"top":
				position_value = position_value_top
			"bottom":
				position_value = position_value_bottom
			_:
				position_value = position_value_bottom
	else:
		position_value = position_value_bottom
		
	return {
		POSITION_PATH: position_value
	}

## 生成DialogueTexture节点的动画值
func _generate_animation_path_value_pairs_dialoguetexture(token: Dictionary, dialogue: String) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/DialogueTexture"
	
	# 属性路径
	const DIALOGUE_STYLE_PATH = "%s:dialogue_style" % NODE_PATH
	const TEXT_ANIMATION_STATE_PATH = "%s:text_animation_state" % NODE_PATH
	
	# 可能的属性值
	var text_animation_state_value_playing = "playing"
	var text_animation_state_value_ended = "ended"
	
	# 初始化属性值
	var dialogue_style_value = token["bbcode_tags"]["world_state"]["value"] if token["bbcode_tags"].has("world_state") else "light"
	var text_animation_state_value = null
	
	# 处理text_animation_state属性
	if token["char_index"] == len(DialogueBbcodeTagsCleaner.clean_bbcode_tags_from_dialogue(dialogue)) - 1:
		text_animation_state_value = text_animation_state_value_ended
	else:
		text_animation_state_value = text_animation_state_value_playing
		
	return {
		DIALOGUE_STYLE_PATH: dialogue_style_value,
		TEXT_ANIMATION_STATE_PATH: text_animation_state_value
	}
	
## 生成DialogueTextureDark节点的动画值
func _generate_animation_path_value_pairs_dialoguetexturedark(token: Dictionary) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/DialogueTextureDark"
	
	# 属性路径
	const VISIBLE_PATH = "%s:visible" % NODE_PATH
	
	# 可能的属性值
	var visible_value_dark = true
	var visible_value_light = false
	
	# 初始化最终属性
	var visible_value = null
	
	# 判断visible属性
	if token["bbcode_tags"].has("world_state"):
		match token["bbcode_tags"]["world_state"]["value"]:
			"dark":
				visible_value = visible_value_dark
			"light":
				visible_value = visible_value_light
			_:
				visible_value = visible_value_light
	else:
		visible_value = visible_value_light
		
	return {
		VISIBLE_PATH: visible_value
	}
	
## 生成DialogueTextureDark节点的动画值
func _generate_animation_path_value_pairs_dialoguetexturelight(token: Dictionary) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/DialogueTextureLight"
	
	# 属性路径
	const VISIBLE_PATH = "%s:visible" % NODE_PATH
	
	# 可能的属性值
	var visible_value_dark = false
	var visible_value_light = true
	
	# 初始化最终属性
	var visible_value = null
	
	# 判断visible属性
	if token["bbcode_tags"].has("world_state"):
		match token["bbcode_tags"]["world_state"]["value"]:
			"dark":
				visible_value = visible_value_dark
			"light":
				visible_value = visible_value_light
			_:
				visible_value = visible_value_light
	else:
		visible_value = visible_value_light
		
	return {
		VISIBLE_PATH: visible_value
	}
	
## 生成CharacterFace节点的动画值
func _generate_animation_path_value_pairs_characterface(token: Dictionary) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/CharacterFace"
	
	# 属性路径
	const TEXTURE_PATH = "%s:texture" % NODE_PATH
	const VISIBLE_PATH = "%s:visible" % NODE_PATH

	const EMPTY_RESULT = { TEXTURE_PATH: null, VISIBLE_PATH: false }

	if (not "bbcode_tags" in token) or (not "face" in token["bbcode_tags"]):
		return EMPTY_RESULT
	
	# 可能的属性值
	if not "value" in token["bbcode_tags"]["face"]:
		return EMPTY_RESULT
	var texture_value_cf = AssetLoader.load_asset(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_FACES, token["bbcode_tags"]["face"]["value"])[0]) if token["bbcode_tags"].has("face") and len(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_FACES, token["bbcode_tags"]["face"]["value"])) == 1 else null
	var texture_value_ncf = null
	var visible_value_cf = true
	var visible_value_ncf = false
	
	# 初始化最终属性
	var texture_value = null
	var visible_value = null
	
	# 判断texture
	if token["bbcode_tags"].has("face"):
		texture_value = texture_value_cf
	else:
		texture_value = texture_value_ncf
	
	# 判断visible
	if token["bbcode_tags"].has("face"):
		visible_value = visible_value_cf
	else:
		visible_value = visible_value_ncf
		
	return {
		TEXTURE_PATH: texture_value,
		VISIBLE_PATH: visible_value
	}
	
## 生成PlaceholderChar节点的动画值
func _generate_animation_path_value_pairs_placeholderchar(token: Dictionary) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/PlaceholderChar"
	
	# 属性路径
	const POSITION_PATH = "%s:position" % NODE_PATH
	
	# 可能的属性值
	var position_value_cf = Vector2(299, 58)
	var position_value_ncf = Vector2(69, 58)
	
	# 初始化最终属性
	var position_value = null
	
	# 判断position
	if token["bbcode_tags"].has("face"):
		position_value = position_value_cf
	else:
		position_value = position_value_ncf
		
	return {
		POSITION_PATH: position_value
	}
	
## 生成PlaceholderChar/Shadow节点的动画值
func _generate_animation_path_value_pairs_placeholderchar_shadow(token: Dictionary) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/PlaceholderChar/Shadow"
	
	# 属性路径
	const VISIBLE_PATH = "%s:visible" % NODE_PATH
	
	# 可能的属性值
	var visible_value_dark = true
	var visible_value_light = false
	
	# 初始化最终属性
	var visible_value = null
	
	# 判断visible
	if token["bbcode_tags"].has("world_state"):
		match token["bbcode_tags"]["world_state"]["value"]:
			"dark":
				visible_value = visible_value_dark
			"light":
				visible_value = visible_value_light
			_:
				visible_value = visible_value_light
	else:
		visible_value = visible_value_light
		
	return {
		VISIBLE_PATH: visible_value
	}
	
## 生成Text节点的动画值
func _generate_animation_path_value_pairs_text(token: Dictionary) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/Text"
	
	# 属性路径
	const POSITION_PATH = "%s:position" % NODE_PATH
	const SIZE_PATH = "%s:size" % NODE_PATH
	
	# 可能的属性值
	var position_value_cf = Vector2(362, 63)
	var position_value_ncf = Vector2(132, 63)
	var size_value_cf = Vector2(732, 225)
	var size_value_ncf = Vector2(962, 225)
	
	# 初始化最终属性
	var position_value = null
	var size_value = null
	
	# 判断position
	if token["bbcode_tags"].has("face"):
		position_value = position_value_cf
	else:
		position_value = position_value_ncf
		
	# 判断size
	if token["bbcode_tags"].has("face"):
		size_value = size_value_cf
	else:
		size_value = size_value_ncf
		
	return {
		POSITION_PATH: position_value,
		SIZE_PATH: size_value
	}
	
## 生成Text/Text节点的动画值
func _generate_animation_path_value_pairs_text_text(token: Dictionary, dialogue: String) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/Text/Text"
	
	# 属性路径
	const TEXT_PATH = "%s:text" % NODE_PATH
	const VISIBLE_CHARACTERS_PATH = "%s:visible_characters" % NODE_PATH
	
	# 属性值
	var text_value = DialogueBbcodeTagsCleaner.clean_bbcode_tags_from_dialogue(dialogue, DialogueBbcodeTagsCleaner.CONTROLLER_TAGS)
	var visible_characters_value = token["char_index"] + 1
	
	return {
		TEXT_PATH: text_value,
		VISIBLE_CHARACTERS_PATH: visible_characters_value
	}
	
## 生成Text/Shadow节点的动画值
func _generate_animation_path_value_pairs_text_shadow(token: Dictionary, dialogue: String) -> Dictionary:
	# 节点路径
	const NODE_PATH = "Dialogue/Text/Shadow"
	
	# 属性路径
	const TEXT_PATH = "%s:text" % NODE_PATH
	const VISIBLE_CHARACTERS_PATH = "%s:visible_characters" % NODE_PATH
	const VISIBLE_PATH = "%s:visible" % NODE_PATH
	
	# 可能的属性值
	var visible_value_dark = true
	var visible_value_light = false
	
	# 初始化属性值
	var text_value = DialogueBbcodeTagsCleaner.clean_bbcode_tags_from_dialogue(dialogue, DialogueBbcodeTagsCleaner.CONTROLLER_TAGS)
	var visible_characters_value = token["char_index"] + 1
	var visible_value = null
	
	# 判断visible属性
	if token["bbcode_tags"].has("world_state"):
		match token["bbcode_tags"]["world_state"]["value"]:
			"dark":
				visible_value = visible_value_dark
			"light":
				visible_value = visible_value_light
			_:
				visible_value = visible_value_light
	else:
		visible_value = visible_value_light
		
	return {
		TEXT_PATH: text_value,
		VISIBLE_CHARACTERS_PATH: visible_characters_value,
		VISIBLE_PATH: visible_value
	}
				
