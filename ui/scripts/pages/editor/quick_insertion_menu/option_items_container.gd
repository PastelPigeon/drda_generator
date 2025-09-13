extends VBoxContainer

func _ready() -> void:
	# 连接信号
	owner.quick_insertion_id_property_changed.connect(_on_quick_insertion_id_property_changed)

## 当快速插入id发生改变时执行
func _on_quick_insertion_id_property_changed():
	# 清除所有子控件
	for option_item in get_children():
		remove_child(option_item)
	
	# 获取指定快速插入信息
	var quick_insertion_info = QuickInsertionsManager.get_quick_insertion_info(owner.quick_insertion_id)
	
	# 遍历信息中的选项，创建子控件
	for option in quick_insertion_info["options"]:
		# 获取子控件实例
		var quick_insertion_menu_option_item_scene_res: PackedScene = load("res://ui/pages/editor/quick_insertion_menu_option_item.tscn")
		var quick_insertion_menu_option_item_scene_ins = quick_insertion_menu_option_item_scene_res.instantiate()
		
		# 设置子控件属性
		quick_insertion_menu_option_item_scene_ins.option_id = option["id"]
		quick_insertion_menu_option_item_scene_ins.option_type = option["type"]
		quick_insertion_menu_option_item_scene_ins.option_default = option["default"]
		
		# 添加控件
		add_child(quick_insertion_menu_option_item_scene_ins)
