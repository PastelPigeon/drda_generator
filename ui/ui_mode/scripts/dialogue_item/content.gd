extends TextEdit

func _input(event: InputEvent) -> void:
	# 更新内容
	owner.content = text
