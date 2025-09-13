extends Button

var dialogue_editor_content_edit: Control ## 编辑框节点
var quick_insertion_menu: Control ## 快速插入菜单节点

var quick_insertion_id: String: ## 快速插入id
	set(value):
		quick_insertion_id = value
		quick_insertion_info = QuickInsertionsManager.get_quick_insertion_info(value)

var quick_insertion_info: Dictionary ## 快速插入信息

func _ready() -> void:
	# 连接信号
	dialogue_editor_content_edit.selection_changed.connect(_on_dialogue_editor_content_edit_selection_changed)
	
	# 初始时默认禁用
	disabled = true

func _pressed() -> void:
	# 显示快速插入菜单
	quick_insertion_menu.show_menu(quick_insertion_id)

## 当编辑框选中内容改变时执行
func _on_dialogue_editor_content_edit_selection_changed(start_char_index, end_char_index):
	# 判断该按钮是否应该被禁用
	match quick_insertion_info["type"]:
		"wrappered":
			if start_char_index == end_char_index:
				disabled = true
			else:
				disabled = false
		"closed":
			if start_char_index == end_char_index:
				disabled = false
			else:
				disabled = true
