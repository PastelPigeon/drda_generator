extends VBoxContainer

signal category_id_property_changed ## 当指定分区id属性变化时执行

@export var category_id: String: ## 指定分区id
	set(value):
		category_id = value
		
func _ready() -> void:
	# 连接信号
	category_id_property_changed.connect(_update_ui)
	
	# 手动更新ui
	_update_ui()
		
## 更新ui
func _update_ui():
	# 获取指定分区信息
	var category_info = DocManager.get_category_info(category_id)
	
	# 设置分区标题
	%Title.text = category_info["title"]
	
	# 当有图标的情况下设置图标
	if category_info["icon"] != "":
		%Icon.visible = true
		%Icon.texture = AssetLoader.load_asset(category_info["icon"])
	else:
		%Icon.visible = false
		
	# 获取分区下所有文章信息
	var article_infos = DocManager.get_article_ids(category_id).map(func (article_id): return DocManager.get_article_info(category_id, article_id))
	
	# 删除列表中所有项
	%ArticlesItemList.clear()
	
	# 在列表中添加项
	for article_info in article_infos:
		var index = %ArticlesItemList.add_item(article_info["title"])
		%ArticlesItemList.set_item_metadata(index, article_info["id"])
