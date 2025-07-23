extends VBoxContainer

signal dialogues_changed ## 当dialogues改变
signal selected_dialogue_id_changed ## 当selected_dialogue_id改变

var dialogues: Array: ## 存放对话数据
	set(value):
		dialogues = value
		dialogues_changed.emit()
		
var selected_dialogue_id: int: ## 选中的对话的id
	set(value):
		selected_dialogue_id = value
		selected_dialogue_id_changed.emit()
		
func _ready() -> void:
	# 初始化
	dialogues = []
	selected_dialogue_id = -1
		
## 添加对话
func add_dialogue():
	# 生成随机对话id
	var dialogue_id = randi_range(100000, 999999)
	
	# 添加dialogues
	var dialogues_temp = dialogues.duplicate()
	
	dialogues_temp.append(
		{
			"dialogue_id": dialogue_id,
			"content": ""
		}
	)
	
	dialogues = dialogues_temp
	
	# 添加ui
	var dialogue_item_scene_res: PackedScene = load("res://ui/ui_mode/dialogue_item.tscn")
	var dialogue_item_scene_ins = dialogue_item_scene_res.instantiate()
	add_child(dialogue_item_scene_ins)
	
	# 设置属性
	dialogue_item_scene_ins.dialogue_id = dialogue_id
	dialogue_item_scene_ins.dialogues = self
	
	# 连接信号
	dialogue_item_scene_ins.edit_button_pressed.connect(select_dialogue)
	dialogue_item_scene_ins.remove_button_pressed.connect(remove_dialogue)
	
	# 选中新对话
	select_dialogue(dialogue_id)
	
## 删除指定对话
func remove_dialogue(dialogue_id: int):
	# 判断对话是否存在
	if len(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)) == 0:
		return
		
	# 获取对话index
	var dialogue_index = dialogues.find(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)[0])
	
	# 当要删除的对话为选中的对话时，特殊处理
	if selected_dialogue_id == dialogue_id:
		if dialogue_index == 0:
			# 当没有上一个对话时，不选择对话
			selected_dialogue_id = -1
		else:
			# 默认情况选择上一个对话
			selected_dialogue_id = dialogues[dialogue_index - 1]["dialogue_id"]
			
	# 删除ui
	remove_child(get_child(dialogue_index))
	
	# 从dialogues中删除
	var dialogues_temp = dialogues.duplicate()
	dialogues_temp.remove_at(dialogue_index)
	dialogues = dialogues_temp
	
## 选中对话
func select_dialogue(dialogue_id: int):
	# 判断对话是否存在
	if len(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)) == 0:
		return
	
	selected_dialogue_id = dialogue_id
	
## 设置对话内容
func set_dialogue_content(dialogue_id: int, content: String):
	# 判断对话是否存在
	if len(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)) == 0:
		return
		
	# 获取对话index
	var dialogue_index = dialogues.find(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)[0])
		
	# 设置内容
	var dialogues_temp = dialogues.duplicate()
	dialogues_temp[dialogue_index]["content"] = content
	dialogues = dialogues_temp
	
## 获取所有对话内容
func get_dialogues_content():
	return dialogues.map(func (dialogue): return dialogue["content"])
