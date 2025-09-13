extends Button

func _pressed() -> void:
	# 初始化选项字典
	var options = {}
	
	# 添加选项信息
	for option_item in %OptionItemsContainer.get_children():
		options[option_item.option_id] = option_item.get_value()
		
	# 发送信号
	owner.quick_insertion_menu_insert_button_pressed.emit(owner.quick_insertion_id, options)
	
	# 隐藏菜单
	owner.visible = false
