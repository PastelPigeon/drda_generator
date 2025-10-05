extends RichTextLabel

func _ready() -> void:
	# 设置初始文本
	text = "[center]正在加载"
	
	# 链接信号
	AutoUpdater.release_info_loaded.connect(_on_release_info_loaded)

## 当发布信息加载完成时
func _on_release_info_loaded(release_info: AutoUpdater.ReleaseInfo):
	# 设置文本
	text = AutoUpdater.markdown_to_bbcode(release_info.body)
