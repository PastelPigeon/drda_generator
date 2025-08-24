extends VBoxContainer

func _ready() -> void:
	# 获取所有分区id
	var category_ids = DocManager.get_category_ids()
	
	# 遍历分区id，添加项
	for category_id in category_ids:
		# 获取实例
		var categories_bar_item_scene_res: PackedScene = load("res://ui/pages/doc/categories_bar_item.tscn")
		var categories_bar_item_scene_ins = categories_bar_item_scene_res.instantiate()
		
		# 设置属性
		categories_bar_item_scene_ins.category_id = category_id
		
		# 添加到子节点
		add_child(categories_bar_item_scene_ins)
