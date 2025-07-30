extends Control

signal current_page_index_changed ## 当选中页面的索引变化时发出

var current_page_index: int: ## 选中页面的索引编号
	set(value):
		current_page_index = value
		current_page_index_changed.emit()
		
func _ready() -> void:
	# 初始时选中编辑页面
	current_page_index = 0
