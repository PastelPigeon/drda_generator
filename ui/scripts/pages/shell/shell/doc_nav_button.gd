extends Button

const PAGE_INDEX = 4 ## 该按钮所对应的页面索引

func _ready() -> void:
	# 连接信号
	owner.current_page_index_changed.connect(_on_current_page_index_changed)

## 当选中的页面索引变化时执行
func _on_current_page_index_changed():
	# 判断当前选中的页面索引是否为自己所对应的页面索引
	if owner.current_page_index == PAGE_INDEX:
		# 是自己的页面索引，将自己的样式设置为选中样式
		theme_type_variation = "pages_nav_button_current_page"
	else:
		# 不是自己的页面索引，将自己的样式设置为一般样式
		theme_type_variation = ""
		
func _pressed() -> void:
	# 将选中的页面索引设置为自己对应的页面索引
	owner.current_page_index = PAGE_INDEX
