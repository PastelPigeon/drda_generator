extends Button

func _pressed() -> void:
	# 插入结束标签
	%ContentEdit.insert_text_at_caret("[/]")
