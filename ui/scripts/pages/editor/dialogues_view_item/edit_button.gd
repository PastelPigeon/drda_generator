extends Button

func _pressed() -> void:
	# 选中对话
	EditorDialoguesManager.select_dialogue(owner.dialogue_id)
