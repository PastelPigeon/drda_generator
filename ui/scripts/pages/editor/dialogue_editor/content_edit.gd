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
	
func _unhandled_input(event: InputEvent) -> void:
	# 处理快捷输入
	if event.is_action_pressed("ui_editor_dialogue_editor_content_edit_insert_en_font"):
		# 快速插入英文字体样式
		insert_text_at_caret("[font=res://assets/fonts/dtm.tres][font_size=48]")
	elif event.is_action_pressed("ui_editor_dialogue_editor_content_edit_insert_zh_font"):
		# 快速插入中文字体样式
		insert_text_at_caret("[font=res://assets/fonts/fzb.tres][font_size=48]")
	elif event.is_action_pressed("ui_editor_dialogue_editor_content_edit_insert_world_state_dark"):
		# 快速插入暗世界对话框样式
		insert_text_at_caret("[world_state=dark]")
