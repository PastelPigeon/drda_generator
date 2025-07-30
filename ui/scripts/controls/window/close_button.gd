extends Button

func _pressed() -> void:
	# 应用内弹窗不执行任何操作
	if owner.is_dialog:
		return
		
	# 退出程序
	get_tree().quit()
