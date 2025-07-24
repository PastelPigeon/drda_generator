extends Button

func _pressed() -> void:
	# 当为弹窗时，不执行操作
	if owner.dialog:
		return
		
	# 退出程序
	get_tree().quit()
