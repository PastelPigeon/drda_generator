extends "res://ui/scripts/controls/window/close_button.gd"

func _pressed() -> void:
	# 关闭弹窗
	owner.owner.visible = false
