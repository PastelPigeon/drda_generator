extends Node

 ## 快速插入资产文件夹
const QUICK_INSERTIONS_DIR = "res://ui/assets/quick_insertions"

## 获取所有快速插入id
func get_quick_insertion_ids():
	# 判断注册文件是否存在，不存在直接返回
	if FileAccess.file_exists("%s/%s" % [QUICK_INSERTIONS_DIR, "registry.json"]) == false:
		return
		
	# 读取注册文件
	var registry_file = FileAccess.open("%s/%s" % [QUICK_INSERTIONS_DIR, "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file.get_as_text())
	registry_file.close()
	
	# 返回所有快速插入id
	return registry.keys()
	
## 获取指定快速插入信息
func get_quick_insertion_info(quick_insertion_id: String):
	# 判断注册文件是否存在，不存在直接返回
	if FileAccess.file_exists("%s/%s" % [QUICK_INSERTIONS_DIR, "registry.json"]) == false:
		return
		
	# 读取注册文件
	var registry_file = FileAccess.open("%s/%s" % [QUICK_INSERTIONS_DIR, "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file.get_as_text())
	registry_file.close()
	
	# 获取所有快速插入id
	var quick_insertion_ids = registry.keys()
	
	# 判断指定快速插入是否存在于注册文件，不存在直接返回
	if quick_insertion_ids.has(quick_insertion_id) == false:
		return
		
	# 获取指定快速插入信息文件路径
	var quick_insertion_info_path = registry[quick_insertion_id]
	
	# 判断指定快速插入信息文件是否存在，不存在直接返回
	if FileAccess.file_exists(quick_insertion_info_path) == false:
		return
		
	# 读取快速插入信息文件
	var quick_insertion_info_file = FileAccess.open(quick_insertion_info_path, FileAccess.READ)
	var quick_insertion_info = JSON.parse_string(quick_insertion_info_file.get_as_text())
	quick_insertion_info_file.close()
	
	# 返回指定快速插入信息
	return quick_insertion_info
