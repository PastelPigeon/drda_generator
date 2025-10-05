extends "res://ui/scripts/controls/window/window.gd"

func _ready() -> void:
	# 链接信号
	AutoUpdater.update_available.connect(_on_update_available)
	
	# 检查更新
	AutoUpdater.check_update()

## 当更新可用时
func _on_update_available(latest_version: String, current_version: String):
	# 显示弹窗
	visible = true
	
	# 获取发布信息
	AutoUpdater.get_release_info()
