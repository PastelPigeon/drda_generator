extends "res://ui/scripts/pages/editor/quick_insertion_buttons_container/quick_insertion_buttons_container.gd"

func _ready() -> void:
	# 设置属性
	dialogue_editor_content_edit = %ContentEdit
	quick_insertion_menu = owner.quick_insertion_menu
	
	_update_ui()
