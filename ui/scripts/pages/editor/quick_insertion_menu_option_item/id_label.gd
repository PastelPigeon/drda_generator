extends Label

func _ready() -> void:
	# 连接信号
	owner.option_id_property_changed.connect(_on_option_id_property_changed)
	owner.option_type_property_changed.connect(_on_option_type_property_changed)
	owner.option_default_property_changed.connect(_on_option_default_property_changed)

## 当选项id发生改变时执行
func _on_option_id_property_changed():
	# 设置文本
	text = owner.option_id
	
## 当选项类型发生改变时执行
func _on_option_type_property_changed():
	pass
	
## 当选项默认值发生改变时执行
func _on_option_default_property_changed():
	pass
