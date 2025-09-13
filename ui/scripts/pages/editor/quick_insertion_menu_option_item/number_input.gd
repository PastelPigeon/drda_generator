extends SpinBox

## 对应的选项类型
const OPTION_TYPE = "number"

func _ready() -> void:
	# 连接信号
	owner.option_id_property_changed.connect(_on_option_id_property_changed)
	owner.option_type_property_changed.connect(_on_option_type_property_changed)
	owner.option_default_property_changed.connect(_on_option_default_property_changed)

## 当选项id发生改变时执行
func _on_option_id_property_changed():
	# 判断是否为对应的选项类型，不是对应的选项类型直接返回
	if owner.option_type["type"] != OPTION_TYPE:
		return
		
	pass
	
## 当选项类型发生改变时执行
func _on_option_type_property_changed():
	# 判断是否为对应的选项类型，不是对应的选项类型直接返回
	if owner.option_type["type"] != OPTION_TYPE:
		return
		
	# 设置属性
	min_value = owner.option_type["min_value"]
	max_value = owner.option_type["max_value"]
	step = owner.option_type["step"]
	
## 当选项默认值发生改变时执行
func _on_option_default_property_changed():
	# 判断是否为对应的选项类型，不是对应的选项类型直接返回
	if owner.option_type["type"] != OPTION_TYPE:
		return
		
	# 设置值
	value = owner.option_default
