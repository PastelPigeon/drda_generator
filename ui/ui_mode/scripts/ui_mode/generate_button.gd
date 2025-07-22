extends Button

func _pressed() -> void:
	_run_generator()

## 运行生成器
func _run_generator():
	# 获取生成参数
	var cmdline_args = _get_cmdline_args()
	
	if OS.is_debug_build():
		# 编辑器中不运行，只打印运行参数
		print(cmdline_args)
		print("编辑器中无法运行生成器")
	else:
		# 运行生成器
		OS.execute(OS.get_executable_path(), cmdline_args)
	

## 生成生成器所使用的参数
func _get_cmdline_args():
	# 处理dialogues
	var dialogues = []
	
	# 遍历Dialogues的子控件，获取dialogues内容
	for dialogue_item in %Dialogues.get_children():
		dialogues.append(dialogue_item.content)
		
	# 将dialogues存储为临时文件并获取其路径
	var dialogues_file_path = TempFilesManager.create_temp_file(JSON.stringify(dialogues), "json")
	
	# 获取options
	var fps = float(%FpsInput.value) 
	var background = "#%s" % %BackgroundInput.color.to_html()
	var recording_mode = "single" if %RecordingModeInput.selected == 0 else "multiple"
	var recordings_output_dir = %RecordingsOutputDirInput.text
	
	return CmdlineParser.convert_cmdline_args_dict_to_array(
		{
			"dialogues": dialogues_file_path,
			"fps": fps,
			"background": background,
			"recording_mode": recording_mode,
			"recordings_output_dir": recordings_output_dir
		}
	)
