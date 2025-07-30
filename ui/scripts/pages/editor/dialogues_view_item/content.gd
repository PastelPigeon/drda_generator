extends Label

func _ready() -> void:
	# 连接信号
	EditorDialoguesManager.dialogues_changed.connect(_on_dialogues_changed)
	
	# 初始化时手动执行一次_on_dialogues_changed
	_on_dialogues_changed(EditorDialoguesManager.DialoguesChangedType.ITEM_CONTENT_CHANGED)

## 当dialogues改变时执行
func _on_dialogues_changed(type: EditorDialoguesManager.DialoguesChangedType):
	# 判断dialogues的变化类型是否为content，不是直接返回，不进行下一步操作
	if type != EditorDialoguesManager.DialoguesChangedType.ITEM_CONTENT_CHANGED:
		return
		
	# 判断dialogues数组中是否存在该项的dialogue_id，不存在直接返回，不进行下一步操作
	if len(EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == owner.dialogue_id)) == 0:
		return
		
	# 更新文本
	var raw_content = EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == owner.dialogue_id)[0]["content"]
	var cleaned_content = DialogueBbcodeTagsCleaner.clean_bbcode_tags_from_dialogue(raw_content)
	text = cleaned_content if cleaned_content != "" else "没有可见字符"
	
	# 更新样式
	if cleaned_content == "":
		# 没有任何内容时，采用no_content样式
		theme_type_variation = "dialogues_view_item_content_label_no_content"
	else:
		# 有内容时，采用一般样式
		theme_type_variation = "dialogues_view_item_content_label"
