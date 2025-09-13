extends Control

signal quick_insertion_id_property_changed ## 当快速插入id发生改变时发出
signal quick_insertion_menu_insert_button_pressed(quick_insertion_id: String, options: Dictionary) ## 当插入按钮点下时发出

var quick_insertion_id: String: ## 快速插入id
	set(value):
		quick_insertion_id = value
		quick_insertion_id_property_changed.emit()
		
## 显示菜单
func show_menu(id: String):
	# 设置快速插入id
	quick_insertion_id = id
	
	# 显示菜单
	visible = true
