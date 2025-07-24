extends Button

func _pressed() -> void:
	# 打开文件选择对话框
	DisplayServer.file_dialog_show("选择输出路径", UmOptionsConfigManager.get_options()["recordings_output_dir"], "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], _on_dir_selected)

## 处理文件选择器的回调函数
func _on_dir_selected(status:bool, selected_paths:PackedStringArray, _selected_filter_index:int):
	# 如果未选择直接返回，不进行任何操作
	if status == false:
		return
		
	# 选择则设置RecordingsOutputDirInput的值
	%RecordingsOutputDirInput.text = selected_paths[0]
	
	# 手动存储选项
	UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.RECORDINGS_OUTPUT_DIR, selected_paths[0])
