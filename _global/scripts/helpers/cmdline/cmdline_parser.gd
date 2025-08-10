extends Node

const DEFAULT = {
	"dialogues": "",
	"fps": 24.0,
	"background": "green",
	"recording_mode": "single",
	"recordings_output_dir": "",
	"recording_format": "mp4",
	"recording_enable_transparent": false,
	"external_assets_manifest": ""
}

enum CmdlineStatus {
	OK,
	EDITOR,
	UI_MODE,
	DOC_MODE,
	NO_DIALOGUES,
	INVALID_DIALOGUES,
	INVALID_DIALOGUES_FILE,
	INVALID_FPS,
	INVALID_BACKGROUND,
	INVALID_RECORDING_MODE,
	NO_RECORDINGS_OUTPUT_DIR,
	INVALID_RECORDINGS_OUTPUT_DIR,
	INVALID_RECORDING_FORMAT,
	INVALID_RECORDING_ENABLE_TRANSPARENT,
	RECORDING_ENABLE_TRANSPARENT_NOT_SUPPORTED,
	INVALID_EXTERNAL_ASSETS_MANIFEST,
	INVALID_EXTERNAL_ASSETS_MANIFEST_FILE,
}

## 获取某一参数在命令行中的名称
func _get_arg_cmdline_name(arg: String) -> String:
	return "--%s" % arg
	
## 获取某一参数在cmdline_args数组中是否存在
func _arg_exists_cmdline_args_array(arg: String, cmdline_args: Array) -> bool:
	return cmdline_args.has(_get_arg_cmdline_name(arg))
	
## 获取某一参数在cmdline_args数组中的值（当该参数不存在时返回null）
func _get_arg_value_cmdline_args_array(arg: String, cmdline_args: Array) -> Variant:
	if _arg_exists_cmdline_args_array(arg, cmdline_args):
		return cmdline_args[cmdline_args.find(_get_arg_cmdline_name(arg)) + 1]
	else:
		return null
		
## 将array形式的cmdline_args转换为dict形式
func convert_cmdline_args_array_to_dict(cmdline_args: Array) -> Dictionary:
	var cmdline_args_dict = DEFAULT.duplicate()
	
	# 处理dialogues参数
	if _arg_exists_cmdline_args_array("dialogues", cmdline_args):
		if FileAccess.file_exists(_get_arg_value_cmdline_args_array("dialogues", cmdline_args)) and JSON.parse_string(FileAccess.open(_get_arg_value_cmdline_args_array("dialogues", cmdline_args), FileAccess.READ).get_as_text()) != null:
			cmdline_args_dict["dialogues"] = _get_arg_value_cmdline_args_array("dialogues", cmdline_args)
			
	# 处理fps参数
	if _arg_exists_cmdline_args_array("fps", cmdline_args):
		if StringTypesChecker.is_float_string(_get_arg_value_cmdline_args_array("fps", cmdline_args)):
			cmdline_args_dict["fps"] = float(_get_arg_value_cmdline_args_array("fps", cmdline_args))
			
	# 处理background参数
	if _arg_exists_cmdline_args_array("background", cmdline_args):
		if StringTypesChecker.is_color_string(_get_arg_value_cmdline_args_array("background", cmdline_args)):
			cmdline_args_dict["background"] = _get_arg_value_cmdline_args_array("background", cmdline_args)
			
	# 处理recording_mode参数
	if _arg_exists_cmdline_args_array("recording_mode", cmdline_args):
		if _get_arg_value_cmdline_args_array("recording_mode", cmdline_args) == "single" or _get_arg_value_cmdline_args_array("recording_mode", cmdline_args) == "multiple":
			cmdline_args_dict["recording_mode"] = _get_arg_value_cmdline_args_array("recording_mode", cmdline_args)
			
	# 处理recordings_output_dir参数
	if _arg_exists_cmdline_args_array("recordings_output_dir", cmdline_args):
		if DirAccess.dir_exists_absolute(_get_arg_value_cmdline_args_array("recordings_output_dir", cmdline_args)):
			cmdline_args_dict["recordings_output_dir"] = _get_arg_value_cmdline_args_array("recordings_output_dir", cmdline_args)
			
	# 处理recording_format参数
	if _arg_exists_cmdline_args_array("recording_format", cmdline_args):
		if _get_arg_value_cmdline_args_array("recording_format", cmdline_args) == "mp4" or _get_arg_value_cmdline_args_array("recording_format", cmdline_args) == "mov" or _get_arg_value_cmdline_args_array("recording_format", cmdline_args) == "gif":
			cmdline_args_dict["recording_format"] = _get_arg_value_cmdline_args_array("recording_format", cmdline_args)
			
	# 处理recording_enable_transparent参数
	if _arg_exists_cmdline_args_array("recording_enable_transparent", cmdline_args):
		if _get_arg_value_cmdline_args_array("recording_enable_transparent", cmdline_args) == "true" or _get_arg_value_cmdline_args_array("recording_enable_transparent", cmdline_args) == "false":
			if _arg_exists_cmdline_args_array("recording_format", cmdline_args):
				if _get_arg_value_cmdline_args_array("recording_format", cmdline_args) == "mov" or _get_arg_value_cmdline_args_array("recording_format", cmdline_args) == "gif":
					cmdline_args_dict["recording_enable_transparent"] = true if _get_arg_value_cmdline_args_array("recording_enable_transparent", cmdline_args) == "true" else false
					
	# 处理external_assets_manifest参数
	if _arg_exists_cmdline_args_array("external_assets_manifest", cmdline_args):
		if FileAccess.file_exists(_get_arg_value_cmdline_args_array("external_assets_manifest", cmdline_args)) and JSON.parse_string(FileAccess.open(_get_arg_value_cmdline_args_array("external_assets_manifest", cmdline_args), FileAccess.READ).get_as_text()) != null:
			cmdline_args_dict["external_assets_manifest"] = _get_arg_value_cmdline_args_array("external_assets_manifest", cmdline_args)
			
	return cmdline_args_dict
	
## 将dict形式的cmdline_args转换为String形式
func convert_cmdline_args_dict_to_string(cmdline_args: Dictionary) -> String:
	# 合并默认arg字典和传入的参数
	var merged_cmdline_args = DictionaryMerger.merge_dictionaries([DEFAULT, cmdline_args])
	
	var cmdline_args_array = []
	
	for arg in merged_cmdline_args:
		cmdline_args_array.append(_get_arg_cmdline_name(arg))
		cmdline_args_array.append(merged_cmdline_args[arg])
		
	return " ".join(cmdline_args_array)
	
	
## 将dict形式的cmdline_args转换为Array形式
func convert_cmdline_args_dict_to_array(cmdline_args: Dictionary) -> Array:
	# 合并默认arg字典和传入的参数
	var merged_cmdline_args = DictionaryMerger.merge_dictionaries([DEFAULT, cmdline_args])
	
	var cmdline_args_array = []
	
	for arg in merged_cmdline_args:
		cmdline_args_array.append(_get_arg_cmdline_name(arg))
		cmdline_args_array.append(merged_cmdline_args[arg])
		
	return cmdline_args_array
	
## 判断传入的cmdline_args的状态
func get_cmdline_args_status(cmdline_args: Array) -> Dictionary:
	if OS.is_debug_build() and len(cmdline_args) == 0:
		return {
			"status": CmdlineStatus.EDITOR,
			"user": ""
		}
	elif OS.is_debug_build() and _arg_exists_cmdline_args_array("editor_ui_mode", cmdline_args):
		return {
			"status": CmdlineStatus.UI_MODE,
			"user": ""
		}
	elif OS.is_debug_build() == false and len(cmdline_args) == 0:
		return {
			"status": CmdlineStatus.UI_MODE,
			"user": ""
		}
	elif  _arg_exists_cmdline_args_array("doc", cmdline_args):
		return {
			"status": CmdlineStatus.DOC_MODE,
			"user": ""
		}
	elif _arg_exists_cmdline_args_array("dialogues", cmdline_args) == false:
		return {
			"status": CmdlineStatus.NO_DIALOGUES,
			"user": "没有传入任何对话文件"
		}
	elif _arg_exists_cmdline_args_array("dialogues", cmdline_args):
		if FileAccess.file_exists(_get_arg_value_cmdline_args_array("dialogues", cmdline_args)) == false:
			return {
				"status": CmdlineStatus.INVALID_DIALOGUES,
				"user": "对话文件不存在"
			}
		elif JSON.parse_string(FileAccess.open(_get_arg_value_cmdline_args_array("dialogues", cmdline_args), FileAccess.READ).get_as_text()) == null:
			return {
				"status": CmdlineStatus.INVALID_DIALOGUES_FILE,
				"user": "对话文件解析时出错"
			}
	elif _arg_exists_cmdline_args_array("fps", cmdline_args):
		if StringTypesChecker.is_float_string(_get_arg_value_cmdline_args_array("fps", cmdline_args)) == false:
			return {
				"status": CmdlineStatus.INVALID_FPS,
				"user": "错误的fps参数形式，预期数字或浮点数（小数）"
			}
	elif _arg_exists_cmdline_args_array("background", cmdline_args):
		if StringTypesChecker.is_color_string(_get_arg_value_cmdline_args_array("background", cmdline_args)) == false:
			return {
				"status": CmdlineStatus.INVALID_BACKGROUND,
				"user": "错误的background参数形式，预期颜色值（hex或颜色名称）"
			}
	elif _arg_exists_cmdline_args_array("recording_mode", cmdline_args):
		if _get_arg_value_cmdline_args_array("recording_mode", cmdline_args) != "single" and _get_arg_value_cmdline_args_array("recording_mode", cmdline_args) != "multiple":
			return {
				"status": CmdlineStatus.INVALID_RECORDING_MODE,
				"user": "错误的recording参数形式，预期single或multiple"
			}
	elif _arg_exists_cmdline_args_array("recordings_output_dir", cmdline_args) == false:
		return {
			"status": CmdlineStatus.NO_RECORDINGS_OUTPUT_DIR,
			"user": "没有指定任何输出路径"
		}
	elif _arg_exists_cmdline_args_array("recordings_output_dir", cmdline_args):
		if DirAccess.dir_exists_absolute(_get_arg_value_cmdline_args_array("recordings_output_dir", cmdline_args)):
			return {
				"status": CmdlineStatus.INVALID_RECORDINGS_OUTPUT_DIR,
				"user": "指定的输出路径不存在"
			}
	elif _arg_exists_cmdline_args_array("recording_format", cmdline_args):
		if _get_arg_value_cmdline_args_array("recording_format", cmdline_args) != "mp4" and _get_arg_value_cmdline_args_array("recording_format", cmdline_args) != "mov" and _get_arg_value_cmdline_args_array("recording_format", cmdline_args) != "gif":
			return {
				"status": CmdlineStatus.INVALID_RECORDING_FORMAT,
				"user": "给出的格式不支持"
			}
	elif _arg_exists_cmdline_args_array("recording_enable_transparent", cmdline_args):
		if _get_arg_value_cmdline_args_array("recording_enable_transparent", cmdline_args) != "true" and _get_arg_value_cmdline_args_array("recording_enable_transparent", cmdline_args) != "false":
			return {
				"status": CmdlineStatus.INVALID_RECORDING_ENABLE_TRANSPARENT,
				"user": "开启透明选项值错误，应为true或者false"
			}
			
		if _get_arg_value_cmdline_args_array("recording_enable_transparent", cmdline_args) == "true" or _get_arg_value_cmdline_args_array("recording_enable_transparent", cmdline_args) == "false":
			if _arg_exists_cmdline_args_array("recording_format", cmdline_args):
				if _get_arg_value_cmdline_args_array("recording_format", cmdline_args) != "mov" and _get_arg_value_cmdline_args_array("recording_format", cmdline_args) != "gif":
					return {
						"status": CmdlineStatus.RECORDING_ENABLE_TRANSPARENT_NOT_SUPPORTED,
						"user": "您所选用的输出格式不支持启用透明选项，请尝试将输出格式更改为mov或gif"
					}
			else:
				return {
					"status": CmdlineStatus.RECORDING_ENABLE_TRANSPARENT_NOT_SUPPORTED,
					"user": "您所选用的输出格式不支持启用透明选项，请尝试将输出格式更改为mov或gif"
				}
	elif _arg_exists_cmdline_args_array("external_assets_manifest", cmdline_args):
		if FileAccess.file_exists(_get_arg_value_cmdline_args_array("external_assets_manifest", cmdline_args)) == false:
			return {
				"status": CmdlineStatus.INVALID_EXTERNAL_ASSETS_MANIFEST,
				"user": "外部资源清单文件不存在"
			}
		elif JSON.parse_string(FileAccess.open(_get_arg_value_cmdline_args_array("external_assets_manifest", cmdline_args), FileAccess.READ).get_as_text()) == null:
			return {
				"status": CmdlineStatus.INVALID_EXTERNAL_ASSETS_MANIFEST_FILE,
				"user": "外部资源清单文件解析时出错"
			}

	return {
		"status": CmdlineStatus.OK,
		"user": ""
	}
