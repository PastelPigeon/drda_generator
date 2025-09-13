extends "res://ui/scripts/controls/window/close_button.gd"

func _pressed() -> void:
	# 隐藏菜单
	owner.owner.visible = false
