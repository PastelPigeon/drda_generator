extends "res://ui/window/scripts/window/close_button.gd"

func _pressed() -> void:
	# 清除临时文件
	TempFilesManager.clean_all_temp_files()
	
	# 退出程序
	get_tree().quit()
