extends Button

func _pressed() -> void:
	# 发送信号
	owner.edit_button_pressed.emit(owner.dialogue_id)
