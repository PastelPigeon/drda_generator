extends VBoxContainer

func _ready() -> void:
	# 连接信号
	EditorDialoguesManager.dialogues_changed.connect(_on_dialogues_changed)

## 当dialogues变化时执行
func _on_dialogues_changed(type: EditorDialoguesManager.DialoguesChangedType):
	# 判断变化类型是否为items，不是直接返回，不进行下一步操作
	if type != EditorDialoguesManager.DialoguesChangedType.ITEMS_CHANGED:
		return
		
	# 删除所有已有对话项
	for dialogue_item in get_children():
		remove_child(dialogue_item)
		
	# 重新添加对话项
	for dialogue_item in EditorDialoguesManager.dialogues:
		# 实例化对话项场景
		var dialogues_view_item_scene_res: PackedScene = load("res://ui/pages/editor/dialogues_view_item.tscn")
		var dialogues_view_item_scene_ins = dialogues_view_item_scene_res.instantiate()
		
		# 设置唯一对话id
		dialogues_view_item_scene_ins.dialogue_id = dialogue_item["dialogue_id"]
		
		# 将实例添加到子节点
		add_child(dialogues_view_item_scene_ins)
