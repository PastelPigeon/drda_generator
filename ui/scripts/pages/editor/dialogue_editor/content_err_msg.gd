extends Label

func _ready() -> void:
	# 连接信号
	EditorDialoguesManager.dialogues_changed.connect(_on_dialogues_changed)
	EditorDialoguesManager.selected_dialogue_id_changed.connect(_on_selected_dialogue_id_changed)

## 当dialogues变化时触发
func _on_dialogues_changed(type: EditorDialoguesManager.DialoguesChangedType):
	# 如果变化类型不为content，直接返回，不进行下一步操作
	if type != EditorDialoguesManager.DialoguesChangedType.ITEM_CONTENT_CHANGED:
		return
		
	_update_ui()
	
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
	
	# 获取错误信息
	var err = EditorBbcodeParser.check_bbcode_string(content)
	var err_msg = EditorBbcodeParser.error_to_string(err)
	
	# 更新文本
	text = err_msg
	
	# 更新样式
	if err == EditorBbcodeParser.BbcodeStringError.NONE:
		# 无错误，样式设为ok
		theme_type_variation = "content_err_msg_label_ok"
	else:
		# 有错误，样式设为err
		theme_type_variation = "content_err_msg_label_err"
