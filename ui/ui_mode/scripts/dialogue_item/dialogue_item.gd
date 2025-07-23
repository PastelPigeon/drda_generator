extends Control

signal edit_button_pressed(dialogue_id: int) ## 当编辑按钮点下时
signal remove_button_pressed(dialogue_id: int) ## 删除按钮点下时

@export var dialogue_id: int ## 唯一dialogue_id

@export var dialogues: Control: ## Dialogues节点
	set(value):
		# 设置值
		dialogues = value
		
		# 判断值是否为空
		if dialogues != null:
			# 连接信号
			dialogues.dialogues_changed.connect(_on_dialogues_changed)
			dialogues.selected_dialogue_id_changed.connect(_on_selected_dialogue_id_changed)
			
			# 手动执行一次信号接受时所执行的函数
			_on_dialogues_changed()
			_on_selected_dialogue_id_changed()

## 在dialogues变量改变时		
func _on_dialogues_changed():
	# 更新Content节点
	if len(dialogues.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)) != 0:
		var content = DialogueBbcodeTagsCleaner.clean_bbcode_tags_from_dialogue(dialogues.dialogues[dialogues.dialogues.find(dialogues.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)[0])]["content"])
		$"Content".text = content if content != "" else "没有可见字符"
	
## 在selected_dialogue_id改变时
func _on_selected_dialogue_id_changed():
	pass
