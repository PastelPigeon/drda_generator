extends Button

func _pressed() -> void:
	# 发送信号
	owner.remove_button_pressed.emit(owner.dialogue_id)
