extends Button

func _pressed() -> void:
	_add_dialogue_item()

## 添加一个新的dialogue_item
func _add_dialogue_item():
	# 将dialogue_item实例添加到Dialogues
	var dialogue_item_scene_res: PackedScene = load("res://ui/ui_mode/dialogue_item.tscn")
	var dialogue_item_scene_ins = dialogue_item_scene_res.instantiate()
	%Dialogues.add_child(dialogue_item_scene_ins)
	
	# 设置dialogue_item参数
	dialogue_item_scene_ins.dialogue_id = randi_range(0, 1000000)
	
	# 连接remove_button_pressed信号
	dialogue_item_scene_ins.remove_button_pressed.connect(_on_dialogue_item_remove_button_pressed)
	
func _on_dialogue_item_remove_button_pressed(dialogue_id: int):
	# 遍历查找指定item
	for dialogue_item in %Dialogues.get_children():
		if dialogue_item.dialogue_id == dialogue_id:
			# 删除item
			%Dialogues.remove_child(dialogue_item)
