extends RichTextLabel

const ARTICLE_NOT_FOUND_TEXT = """
[font_size=30]您所寻找的文章不存在[/font_size]

尝试更新软件版本来解决这个问题
"""

const WELCOME_TEXT = """
[font_size=30]欢迎使用DRDA_GENERATOR帮助文档[/font_size]

选中一篇文章开始浏览
"""

func _ready() -> void:
	# 连接信号
	DocDataManager.selected_article_changed.connect(_on_selected_article_changed)
	
	# 设置默认文本为“欢迎文本”
	text = WELCOME_TEXT

## 当选中文章变化时执行
func _on_selected_article_changed():
	# 获取选中文章内容（当文章不存在时使用”文章不存在文本“进行替换）
	var article_content = DocManager.get_article_content(DocDataManager.selected_article["category_id"], DocDataManager.selected_article["article_id"]) if DocManager.get_article_content(DocDataManager.selected_article["category_id"], DocDataManager.selected_article["article_id"]) != null else ARTICLE_NOT_FOUND_TEXT
	
	# 设置文本
	text = article_content
