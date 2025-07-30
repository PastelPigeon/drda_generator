extends Node

signal dialogues_changed(type: DialoguesChangedType) ## dialogues数组变化时发出
signal selected_dialogue_id_changed ## selected_dialogue_id变化时发出

enum DialoguesChangedType {
	ITEMS_CHANGED,
	ITEM_CONTENT_CHANGED
}

var dialogues: Array: ## 对话数据
	set(value):
		# 暂存旧dialogues数据
		var dialogues_old = dialogues
		
		# 将dialogues设置为新值
		dialogues = value
		
		# 根据旧值和新值的对比确定变化类型，并发送信号
		if len(dialogues_old) == len(dialogues):
			# 当旧值和新值长度相同时，说明项没有变化，只是其中一项的内容发生了变化
			dialogues_changed.emit(DialoguesChangedType.ITEM_CONTENT_CHANGED)
		else:
			# 当旧值和新值的长度不同时，说明项发生了变化
			dialogues_changed.emit(DialoguesChangedType.ITEMS_CHANGED)
			
var selected_dialogue_id: int: ## 选中的对话项的id（-1为不选择任何对话）
	set(value):
		selected_dialogue_id = value
		selected_dialogue_id_changed.emit()
		
func _ready() -> void:
	# 初始化值
	dialogues = []
	selected_dialogue_id = -1
	
## 添加一个新的对话
func add_dialogue():
	# 生成唯一随机dialogue_id（xxxxxx）
	var dialogue_id = randi_range(100000, 999999)
	
	# 将新对话项添加到dialogues数组中
	var dialogues_temp = dialogues.duplicate()
	
	dialogues_temp.append(
		{
			"dialogue_id": dialogue_id,
			"content": ""
		}
	)
	
	dialogues = dialogues_temp
	
	# 选中新的对话
	select_dialogue(dialogue_id)
	
## 删除指定对话
func remove_dialogue(dialogue_id: int):
	# 判断给定的dialogue是否存在于dialogues数组中，不存在直接返回，不进行下一步操作
	if len(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)) == 0:
		return
		
	# 获取指定对话项在dialogues数组中的索引位置
	var dialogue_index = dialogues.find(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)[0])
	
	# 判断将要删除的对话是否为选中对话，如果为选中对话，在删除前需要选中其他对话
	if selected_dialogue_id == dialogue_id:
		# 根据该对话在dialogues中的不同位置做不同的处理
		if dialogue_index == 0:
			# 当该对话前没有其他对话时，不选择任何对话
			select_dialogue(-1)
		else:
			# 当该对话前仍有对话时，选择上一个对话
			select_dialogue(dialogues[dialogue_index - 1]["dialogue_id"])
			
	# 将指定对话项从dialogues数组中删除
	var dialogues_temp = dialogues.duplicate()
	dialogues_temp.remove_at(dialogue_index)
	dialogues = dialogues_temp

## 选中指定对话	
func select_dialogue(dialogue_id: int):
	# 判断给定的dialogue是否存在于dialogues数组中，不存在直接返回，不进行下一步操作（-1的特殊情况不算）
	if len(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)) == 0 and dialogue_id != -1:
		return
		
	# 将selected_dialogue_id设置为给定的dialogue_id
	selected_dialogue_id = dialogue_id
	
## 设置指定对话内容
func set_dialogue_content(dialogue_id: int, content: String):
	# 判断给定的dialogue是否存在于dialogues数组中，不存在直接返回，不进行下一步操作
	if len(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)) == 0:
		return
		
	# 获取指定对话项在dialogues数组中的索引位置
	var dialogue_index = dialogues.find(dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogue_id)[0])
	
	# 设置对话内容
	var dialogues_temp = dialogues.duplicate()
	dialogues_temp[dialogue_index]["content"] = content
	dialogues = dialogues_temp
	
## 获取所有对话项的内容数组
func get_dialogues_content():
	return dialogues.map(func (dialogue): return dialogue["content"])
