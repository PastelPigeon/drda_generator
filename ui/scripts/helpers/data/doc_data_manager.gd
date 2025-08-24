extends Node

signal selected_article_changed ## 当选中的文章变化时发出

## 选中的文章
var selected_article: Dictionary = {
	"category_id": "",
	"article_id": ""
} :
	set(value):
		selected_article = value
		selected_article_changed.emit()
