extends CodeEdit

func _ready() -> void:
	text_changed.connect(_on_text_changed)
	
## 当文本发生变化时
func _on_text_changed():
	# 补全内容
	var completed_content = EditorBbcodeParser.complete_bbcode_string_end_tags(text)
	
	# 发送信号
	owner.content_edit_text_changed.emit(completed_content)
	
	# 更新预览
	%Preview.update_preview(completed_content)
