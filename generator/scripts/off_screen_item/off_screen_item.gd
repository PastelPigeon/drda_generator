extends MarginContainer

signal face_property_changed
signal text_property_changed

@export var face: String: # 脸图id
	set(value):
		face = value
		face_property_changed.emit()
		
@export var text: String: # 对话文本
	set(value):
		text = value
		text_property_changed.emit()
		
func _init() -> void:
	# 连接信号
	face_property_changed.connect(_on_face_property_changed)
	text_property_changed.connect(_on_text_property_changed)
		
## 当face属性变化时执行
func _on_face_property_changed():
	# 设置CharacterFace节点纹理
	$HBoxContainer/CharacterFace.texture = AssetLoader.load_asset(AssetFinder.find_asset(AssetFinder.AssetType.CHARACTER_FACES, face)[0])
	
## 当text属性变化时执行
func _on_text_property_changed():
	# 设置Text节点文本（自动设置文本字体样式）
	$HBoxContainer/MarginContainer/Text.text = AutoTextFontStyleProcesser.set_text_font_style(text, 20, AssetFinder.find_asset(AssetFinder.AssetType.FONTS, "fzb_original")[0], AssetFinder.find_asset(AssetFinder.AssetType.FONTS, "dtm")[0])
