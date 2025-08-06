extends HBoxContainer

signal text_property_changed ## 当选项文本属性变化时发出
signal selected_property_changed ## 当是否选中属性变化时发出

@export var text: String: ## 选项文本
	set(value):
		text = value
		text_property_changed.emit()
		
@export var selected: bool: ## 是否选中
	set(value):
		selected = value
		selected_property_changed.emit()

func _ready() -> void:
	# 连接信号
	text_property_changed.connect(_on_text_property_changed)
	selected_property_changed.connect(_on_selected_property_changed)
		
## 当选项文本属性变化时执行
func _on_text_property_changed():
	# 设置Text节点
	%Text.text = AutoTextFontStyleProcesser.set_text_font_style(text, 48, AssetFinder.find_asset(AssetFinder.AssetType.FONTS, "fzb_original")[0], AssetFinder.find_asset(AssetFinder.AssetType.FONTS, "dtm")[0])
	
## 当是否选中属性变化时执行
func _on_selected_property_changed():
	# 设置Soul节点
	%Soul.texture = load(AssetFinder.find_asset(AssetFinder.AssetType.MISC, "soul")[0]) if selected else null
	
	# 设置Text节点
	%Text.text = "[color=yellow]%s" % %Text.text if selected else %Text.text.replace("[color=yellow]", "")
