extends Control

func _ready() -> void:
	# 连接信号
	owner.option_id_property_changed.connect(_on_option_id_property_changed)
	owner.option_type_property_changed.connect(_on_option_type_property_changed)
	owner.option_default_property_changed.connect(_on_option_default_property_changed)

## 当选项id发生改变时执行
func _on_option_id_property_changed():
	pass
	
## 当选项类型发生改变时执行
func _on_option_type_property_changed():
	# 隐藏所有输入框
	for input in get_children():
		input.visible = false
		
	# 根据选项类型显示指定输入框
	match owner.option_type["type"]:
		"string":
			%StringInput.visible = true
		"number":
			%NumberInput.visible = true
		"options":
			%OptionsInput.visible = true
		"color":
			%ColorInput.visible = true
		"asset":
			%AssetInput.visible = true
	
## 当选项默认值发生改变时执行
func _on_option_default_property_changed():
	pass
