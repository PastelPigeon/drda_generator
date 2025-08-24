extends Node

## 文档目录
const DOC_DIR = "res://ui/assets/doc"

## 获取所有分区id
func get_category_ids():
	# 判断根注册文件是否存在，不存在直接返回
	if FileAccess.file_exists("%s/%s" % [DOC_DIR, "registry.json"]) == false:
		return
		
	# 读取根注册文件
	var root_registry_file = FileAccess.open("%s/%s" % [DOC_DIR, "registry.json"], FileAccess.READ)
	var root_registry = JSON.parse_string(root_registry_file.get_as_text())
	root_registry_file.close()
	
	# 返回所有id
	return root_registry.map(func (category_info): return category_info["id"])
	
## 获取分区信息
func get_category_info(category_id: String):
	# 判断根注册文件是否存在，不存在直接返回
	if FileAccess.file_exists("%s/%s" % [DOC_DIR, "registry.json"]) == false:
		return
		
	# 读取根注册文件
	var root_registry_file = FileAccess.open("%s/%s" % [DOC_DIR, "registry.json"], FileAccess.READ)
	var root_registry = JSON.parse_string(root_registry_file.get_as_text())
	root_registry_file.close()
	
	# 判断指定分区是否存在，不存在直接返回
	if len(root_registry.filter(func (category_info): return category_info["id"] == category_id)) == 0:
		return
		
	# 获取指定分区信息
	var category_info = root_registry.filter(func (category_info): return category_info["id"] == category_id)[0]
	
	# 返回信息
	return category_info
	
## 获取所有文章id
func get_article_ids(category_id: String):
	# 判断根注册文件是否存在，不存在直接返回
	if FileAccess.file_exists("%s/%s" % [DOC_DIR, "registry.json"]) == false:
		return
		
	# 读取根注册文件
	var root_registry_file = FileAccess.open("%s/%s" % [DOC_DIR, "registry.json"], FileAccess.READ)
	var root_registry = JSON.parse_string(root_registry_file.get_as_text())
	root_registry_file.close()
	
	# 判断指定分区是否存在，不存在直接返回
	if len(root_registry.filter(func (category_info): return category_info["id"] == category_id)) == 0:
		return
		
	# 获取指定分区信息
	var category_info = root_registry.filter(func (category_info): return category_info["id"] == category_id)[0]
	
	# 获取分区注册文件路径
	var category_registry_path = category_info["file"]
	
	# 判断分区注册文件是否存在，不存在直接返回
	if FileAccess.file_exists(category_registry_path) == false:
		return
		
	# 读取分区注册文件
	var category_registry_file = FileAccess.open(category_registry_path, FileAccess.READ)
	var category_registry = JSON.parse_string(category_registry_file.get_as_text())
	category_registry_file.close()
	
	# 返回所有id
	return category_registry.map(func (article_info): return article_info["id"])
	
## 获取文章信息
func get_article_info(category_id: String, article_id: String):
	# 判断根注册文件是否存在，不存在直接返回
	if FileAccess.file_exists("%s/%s" % [DOC_DIR, "registry.json"]) == false:
		return
		
	# 读取根注册文件
	var root_registry_file = FileAccess.open("%s/%s" % [DOC_DIR, "registry.json"], FileAccess.READ)
	var root_registry = JSON.parse_string(root_registry_file.get_as_text())
	root_registry_file.close()
	
	# 判断指定分区是否存在，不存在直接返回
	if len(root_registry.filter(func (category_info): return category_info["id"] == category_id)) == 0:
		return
		
	# 获取指定分区信息
	var category_info = root_registry.filter(func (category_info): return category_info["id"] == category_id)[0]
	
	# 获取分区注册文件路径
	var category_registry_path = category_info["file"]
	
	# 判断分区注册文件是否存在，不存在直接返回
	if FileAccess.file_exists(category_registry_path) == false:
		return
		
	# 读取分区注册文件
	var category_registry_file = FileAccess.open(category_registry_path, FileAccess.READ)
	var category_registry = JSON.parse_string(category_registry_file.get_as_text())
	category_registry_file.close()
	
	# 判断指定文章是否存在，不存在直接返回
	if len(category_registry.filter(func (article_info): return article_info["id"] == article_id)) == 0:
		return
		
	# 获取指定文章信息
	var article_info = category_registry.filter(func (article_info): return article_info["id"] == article_id)[0]
	
	# 返回信息
	return article_info
	
## 获取文章内容
func get_article_content(category_id: String, article_id: String):
	# 判断根注册文件是否存在，不存在直接返回
	if FileAccess.file_exists("%s/%s" % [DOC_DIR, "registry.json"]) == false:
		return
		
	# 读取根注册文件
	var root_registry_file = FileAccess.open("%s/%s" % [DOC_DIR, "registry.json"], FileAccess.READ)
	var root_registry = JSON.parse_string(root_registry_file.get_as_text())
	root_registry_file.close()
	
	# 判断指定分区是否存在，不存在直接返回
	if len(root_registry.filter(func (category_info): return category_info["id"] == category_id)) == 0:
		return
		
	# 获取指定分区信息
	var category_info = root_registry.filter(func (category_info): return category_info["id"] == category_id)[0]
	
	# 获取分区注册文件路径
	var category_registry_path = category_info["file"]
	
	# 判断分区注册文件是否存在，不存在直接返回
	if FileAccess.file_exists(category_registry_path) == false:
		return
		
	# 读取分区注册文件
	var category_registry_file = FileAccess.open(category_registry_path, FileAccess.READ)
	var category_registry = JSON.parse_string(category_registry_file.get_as_text())
	category_registry_file.close()
	
	# 判断指定文章是否存在，不存在直接返回
	if len(category_registry.filter(func (article_info): return article_info["id"] == article_id)) == 0:
		return
		
	# 获取指定文章信息
	var article_info = category_registry.filter(func (article_info): return article_info["id"] == article_id)[0]
	
	# 获取文章路径
	var article_path = article_info["file"]
	
	# 判断指定文章是否存在，不存在直接返回
	if FileAccess.file_exists(article_path) == false:
		return
		
	# 读取文章内容
	var article_file = FileAccess.open(article_path, FileAccess.READ)
	var article = article_file.get_as_text()
	article_file.close()
	
	# 返回文章内容
	return article
