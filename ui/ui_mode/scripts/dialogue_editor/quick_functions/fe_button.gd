extends Button

func _pressed() -> void:
	# 插入英文字体数据标签
	%ContentEdit.insert_text_at_caret("[font_size=48][font=res://assets/fonts/dtm_font_variation.tres]")
