extends Button

func _pressed() -> void:
	# 插入暗世界样式标签
	%ContentEdit.insert_text_at_caret("[world_state=dark]")
