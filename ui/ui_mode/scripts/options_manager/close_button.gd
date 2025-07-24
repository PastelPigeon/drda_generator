extends "res://ui/window/scripts/window/close_button.gd"

func _pressed() -> void:
	# 关闭弹窗
	owner.owner.visible = false
