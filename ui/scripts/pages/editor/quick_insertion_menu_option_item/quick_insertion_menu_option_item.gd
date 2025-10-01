extends VBoxContainer

signal option_id_property_changed ## 当选项id发生变化时发出
signal option_type_property_changed ## 当选项类型发生变化时发出
signal option_default_property_changed ## 当选项默认值发生变化时发出

var option_id: String: ## 选项id
	set(value):
		option_id = value
		option_default_property_changed.emit()
		
var option_type: Dictionary: ## 选项类型
	set(value):
		option_type = value
		option_type_property_changed.emit()
		
var option_default: Variant: ## 选项默认值
	set(value):
		option_default = value
		option_default_property_changed.emit()
		
func _ready() -> void:
	# 初始化时手动发送一次信号
	option_id_property_changed.emit()
	option_type_property_changed.emit()
	option_default_property_changed.emit()
		
## 获取选项值
func get_value():
	# 根据选项类型判断获取方式
	match option_type["type"]:
		"string":
			return %StringInput.text
		"number":
			return %NumberInput.value
		"options":
			return %OptionsInput.get_item_text(%OptionsInput.selected)
		"color":
			return "#%s" % %ColorInput.color.to_html()
		"asset":
			return %AssetInput.get_item_text(%AssetInput.selected)
