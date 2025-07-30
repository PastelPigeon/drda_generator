extends Node

const TEMP_DIR = "user://temp_files/"

# 创建临时文件并返回绝对路径
static func create_temp_file(content: String, ext: String = "txt") -> String:
	# 确保临时目录存在
	var dir = DirAccess.open("user://")
	if dir.make_dir_recursive(TEMP_DIR) != OK and DirAccess.open(TEMP_DIR) == null:
		push_error("Failed to create temp directory")
		return ""
	
	# 生成唯一文件名
	var timestamp = Time.get_datetime_string_from_system().replace(":", "_")
	var filename = "temp_%s_%d.%s" % [timestamp, randi(), ext]
	var file_path = TEMP_DIR.path_join(filename)
	
	# 写入内容
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to create temp file: %s" % FileAccess.get_open_error())
		return ""
	
	file.store_string(content)
	file.close()
	
	# 返回绝对路径
	return ProjectSettings.globalize_path(file_path)


# 清理所有临时文件
static func clean_all_temp_files() -> void:
	var dir = DirAccess.open(TEMP_DIR)
	if dir == null:
		# 目录不存在则无需清理
		return
	
	# 遍历并删除所有文件
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = TEMP_DIR.path_join(file_name)
		if not dir.current_is_dir():
			var err = dir.remove(full_path)
			if err != OK:
				push_error("Failed to delete temp file: %s (error %d)" % [full_path, err])
		file_name = dir.get_next()
	dir.list_dir_end()
