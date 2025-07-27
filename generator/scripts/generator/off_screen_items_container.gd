extends HBoxContainer

## 添加一个新的小对话框
func add_item(item_name: String, face: String, text: String):
	# 加载并实例化off_screen_item场景
	var off_screen_item_scene_res: PackedScene = load("res://generator/off_screen_item.tscn")
	var off_screen_item_scene_ins = off_screen_item_scene_res.instantiate()
	
	# 初始化动画相关属性
	off_screen_item_scene_ins.add_theme_constant_override("margin_right", 0)
	off_screen_item_scene_ins.modulate.a = 0
	
	# 设置小对话框属性
	off_screen_item_scene_ins.face = face
	off_screen_item_scene_ins.text = text
	
	# 设置名称
	off_screen_item_scene_ins.name = item_name
	
	# 添加实例到子节点中
	add_child(off_screen_item_scene_ins)
	
## 播放指定小对话框的动画
func play_item_anim(item_name: String, duration: float):
	# 获取小对话框节点
	var off_screen_item = get_node(item_name)
	
	# 新建tween
	var tween = create_tween().set_parallel(true)
	
	# 创建边距动画
	tween.tween_method(
		func (value): off_screen_item.add_theme_constant_override("margin_right", value),
		off_screen_item.get_theme_constant("margin_right"),
		50,
		duration
	)
	
	# 创建透明度动画
	tween.tween_property(
		off_screen_item,
		"modulate:a",
		1,
		duration
	)
	
## 移除指定小对话框
func remove_item(item_name: String):
	remove_child(get_node(item_name))
