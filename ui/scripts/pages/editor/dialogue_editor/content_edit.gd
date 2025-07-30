extends CodeEdit

func _ready() -> void:
	# 连接信号
	EditorDialoguesManager.dialogues_changed.connect(_on_dialogues_changed)
	EditorDialoguesManager.selected_dialogue_id_changed.connect(_on_selected_dialogue_id_changed)
	text_changed.connect(_on_text_changed)

## 当文本变化时执行
func _on_text_changed():
	# 判断指定对话项在dialogues数组中是否存在，不存在直接返回，不进行下一步操作
	if len(EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == EditorDialoguesManager.selected_dialogue_id)) == 0:
		return
	
	# 更新对话项内容
	EditorDialoguesManager.set_dialogue_content(EditorDialoguesManager.selected_dialogue_id, EditorBbcodeParser.complete_bbcode_string_end_tags(text))
	
## 当dialogues变化时触发
func _on_dialogues_changed(type: EditorDialoguesManager.DialoguesChangedType):
	pass
	
## 当selected_dialogue_id变化时执行
func _on_selected_dialogue_id_changed():
	_update_ui()

## 更新ui
func _update_ui():
	# 判断指定对话项在dialogues数组中是否存在，不存在直接返回，不进行下一步操作
	if len(EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == EditorDialoguesManager.selected_dialogue_id)) == 0:
		return
		
	# 获取选中对话内容
	var content = EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == EditorDialoguesManager.selected_dialogue_id)[0]["content"]
	
	# 将文本设为对话内容
	text = content
