extends Button

func _pressed() -> void:
	# 运行生成器
	_run_generator()

## 运行生成器
func _run_generator():
	# 编辑器模式下不运行
	if OS.is_debug_build():
		print("编辑器模式下禁止运行生成器")
		return
		
	# 创建线程
	var thread = Thread.new()
	thread.start(_run_generator_thread_handler)

## _run_generator函数中线程执行的函数
func _run_generator_thread_handler():
	# 显示加载界面
	%Loading.visible = true
	
	# 获取生成器参数
	var cmdline_args = _get_cmdline_args()
	
	# 运行生成器
	OS.execute(OS.get_executable_path(), cmdline_args)
	
	# 隐藏加载页面
	%Loading.visible = false
	
	# 清理临时文件
	TempFilesManager.clean_all_temp_files()

## 获取生成器所需的参数
func _get_cmdline_args():
	# 处理dialogues
	var dialogues_file_path = TempFilesManager.create_temp_file(JSON.stringify(EditorDialoguesManager.get_dialogues_content()), "json")
	
	# 处理options
	var options = OptionsConfigManager.get_options()
	options["background"] = "#%s" % options["background"]
	
	return CmdlineParser.convert_cmdline_args_dict_to_array(
		DictionaryMerger.merge_dictionaries([
			{
				"dialogues": dialogues_file_path
			},
			options
		])
	)
