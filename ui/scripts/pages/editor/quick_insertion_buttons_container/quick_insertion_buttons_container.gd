extends HBoxContainer

var dialogue_editor_content_edit: Control ## 编辑框节点
var quick_insertion_menu: Control ## 快速插入菜单节点

## 更新ui（需要在_ready中调用）
func _update_ui():
	# 获取所有快速插入信息
	var quick_insertions_info = QuickInsertionsManager.get_quick_insertion_ids().map(func (id): return QuickInsertionsManager.get_quick_insertion_info(id))
	
	# 遍历信息，添加按钮
	for quick_insertion_info in quick_insertions_info:
		# 实例化按钮
		var quick_insertion_button_scene_res: PackedScene = load("res://ui/pages/editor/quick_insertion_button.tscn")
		var quick_insertion_button_scene_ins = quick_insertion_button_scene_res.instantiate()
		
		# 设置属性
		quick_insertion_button_scene_ins.quick_insertion_id = quick_insertion_info["id"]
		quick_insertion_button_scene_ins.dialogue_editor_content_edit = dialogue_editor_content_edit
		quick_insertion_button_scene_ins.quick_insertion_menu = quick_insertion_menu
		quick_insertion_button_scene_ins.icon = load(quick_insertion_info["icon"])
		
		# 添加到子节点
		add_child(quick_insertion_button_scene_ins)
