extends Button

## 要添加的内容
const CONTENT = "[font=res://assets/fonts/fzb.tres][font_size=48]"

func _pressed() -> void:
	# 在编辑器光标处添加内容
	%ContentEdit.insert_text_at_caret(CONTENT)
