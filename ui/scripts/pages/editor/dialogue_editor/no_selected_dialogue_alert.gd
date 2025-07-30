extends Control

func _ready() -> void:
	# 连接信号
	EditorDialoguesManager.dialogues_changed.connect(_on_dialogues_changed)
	EditorDialoguesManager.selected_dialogue_id_changed.connect(_on_selected_dialogue_id_changed)
	
	# 手动更新一次ui
	_update_ui()

## 当dialogues变化时触发
func _on_dialogues_changed(type: EditorDialoguesManager.DialoguesChangedType):
	pass
	
## 当selected_dialogue_id变化时执行
func _on_selected_dialogue_id_changed():
	_update_ui()

## 更新ui
func _update_ui():
	# 判断是否选中对话
	if EditorDialoguesManager.selected_dialogue_id == -1:
		# 未选中对话时，显示
		visible = true
	else:
		# 选中对话时，隐藏
		visible = false
