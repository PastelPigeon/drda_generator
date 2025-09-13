extends RichTextLabel

func _ready() -> void:
	# 连接信号
	owner.quick_insertion_id_property_changed.connect(_on_quick_insertion_id_property_changed)

## 当快速插入id发生改变时执行
func _on_quick_insertion_id_property_changed():
	# 获取指定快速插入信息
	var quick_insertion_info = QuickInsertionsManager.get_quick_insertion_info(owner.quick_insertion_id)
	
	# 设置文本
	text = DocManager.get_article_content(quick_insertion_info["doc"]["category"], quick_insertion_info["doc"]["article"]) if DocManager.get_article_content(quick_insertion_info["doc"]["category"], quick_insertion_info["doc"]["article"]) != null else "未找到文档"
