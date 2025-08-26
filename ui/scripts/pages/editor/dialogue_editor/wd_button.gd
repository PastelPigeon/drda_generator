extends Button

## 要添加的内容
const CONTENT = "[world_state=dark]"

func _pressed() -> void:
	# 在编辑器光标处添加内容
	%ContentEdit.insert_text_at_caret(CONTENT)
