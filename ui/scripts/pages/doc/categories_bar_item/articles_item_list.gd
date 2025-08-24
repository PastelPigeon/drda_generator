extends ItemList

func _ready() -> void:
	# 连接信号
	item_selected.connect(_on_item_selected)
	DocDataManager.selected_article_changed.connect(_on_selected_article_changed)

## 当选中项时执行
func _on_item_selected(index: int):
	# 获取选中文章的id
	var article_id = get_item_metadata(index)
	
	# 设置选中项
	DocDataManager.selected_article = {
		"category_id": owner.category_id,
		"article_id": article_id
	}
	
## 当选中文章变化时执行
func _on_selected_article_changed():
	# 如果选中的分区不为当前分区，取消选中任何内容
	if DocDataManager.selected_article["category_id"] != owner.category_id:
		deselect_all()
