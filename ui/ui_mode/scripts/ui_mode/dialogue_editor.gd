extends "res://ui/ui_mode/scripts/dialogue_editor/dialogue_editor.gd"

func _ready() -> void:
	# 连接信号
	content_edit_text_changed.connect(_on_content_edit_text_changed)
	
	# 设置属性
	dialogues = %Dialogues
	
## 当内容编辑器的文字改变时
func _on_content_edit_text_changed(content: String):
	%Dialogues.set_dialogue_content(%Dialogues.selected_dialogue_id, content)
