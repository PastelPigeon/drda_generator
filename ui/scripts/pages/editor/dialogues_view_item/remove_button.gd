extends Button

func _pressed() -> void:
	# 删除对话
	EditorDialoguesManager.remove_dialogue(owner.dialogue_id)
