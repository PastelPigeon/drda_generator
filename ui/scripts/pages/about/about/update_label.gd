extends RichTextLabel

func _ready() -> void:
	# 链接信号
	meta_clicked.connect(_richtextlabel_on_meta_clicked)

## 点击超链接时执行
func _richtextlabel_on_meta_clicked(meta):
	AutoUpdater.update()
