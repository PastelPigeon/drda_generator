extends RichTextLabel

func _ready() -> void:
	# 设置初始文本
	text = "正在加载"
	
	# 链接信号
	AutoUpdater.release_info_loaded.connect(_on_release_info_loaded)
	meta_clicked.connect(_richtextlabel_on_meta_clicked)

## 当发布信息加载完成时
func _on_release_info_loaded(release_info: AutoUpdater.ReleaseInfo):
	# 设置文本
	text = "[url=%s]在github上查看%s版本发行页面" % [release_info.html_url, release_info.tag_name]

## 点击超链接时执行
func _richtextlabel_on_meta_clicked(meta):
	# `meta` 是 Variant 类型，所以将其转换为 String，避免运行时脚本出错。
	OS.shell_open(str(meta))
