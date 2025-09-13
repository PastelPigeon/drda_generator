extends OptionButton

## 对应的选项类型
const OPTION_TYPE = "options"

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
		
	# 清空所有选项
	clear()
		
	# 添加选项
	for option in owner.option_type["options"]:
		add_item(option)
	
## 当选项默认值发生改变时执行
func _on_option_default_property_changed():
	# 判断是否为对应的选项类型，不是对应的选项类型直接返回
	if owner.option_type["type"] != OPTION_TYPE:
		return
		
	# 判断指定选项是否存在，不存在直接返回
	if len(range(item_count).filter(func (count): return get_item_text(count) == owner.option_default)) == 0:
		return
		
	# 设置值
	selected = range(item_count).filter(func (count): return get_item_text(count) == owner.option_default)[0]
