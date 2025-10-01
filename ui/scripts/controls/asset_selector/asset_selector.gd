extends OptionButton

var asset_types: Array: ## 支持的资产类型
	set(value):
		asset_types = value
		_update_ui()

## 更新ui
func _update_ui():
	# 清空旧选项
	clear()
	
	# 刷新运行时注册表
	RuntimeAssetRegistriesManager.create_runtime_registries("user://external_assets/manifest.json")
	
	# 获取合并后的运行时注册表
	var combined_runtime_registry = []
	
	# 遍历支持的资产类型，获取注册表
	for type in asset_types:
		# 获取原始注册文件路径
		var raw_runtime_registry_path = "user://runtime_registries/registry@%s.json" % type
		
		# 判断原始注册文件是否存在，不存在直接跳过
		if FileAccess.file_exists(raw_runtime_registry_path) == false:
			continue
			
		# 读取原始注册文件
		var raw_runtime_registry_file = FileAccess.open(raw_runtime_registry_path, FileAccess.READ)
		var raw_runtime_registry = JSON.parse_string(raw_runtime_registry_file.get_as_text())
		raw_runtime_registry_file.close()
		
		# 加入合并的运行时注册表
		for asset_key in raw_runtime_registry.keys():
			combined_runtime_registry.append(
				{
					"type": type,
					"key": asset_key,
					"files": raw_runtime_registry[asset_key]
				}
			)
			
	# 遍历合并后的运行时注册表，添加选项
	for asset in combined_runtime_registry:
		# 根据不同类型的资产，选择不同的添加方式
		match asset["type"]:
			"character_faces":
				if len(asset["files"]) == 0:
					add_item(asset["key"])
				else:
					add_icon_item(AssetLoader.load_asset(asset["files"][0]), asset["key"])
			"character_sounds":
				add_icon_item(load("res://ui/assets/icons/loudspeaker_rays-1.png"), asset["key"])
			"dialogue_textures":
				if len(asset["files"]) == 0:
					add_item(asset["key"])
				else:
					add_icon_item(AssetLoader.load_asset(asset["files"][0]), asset["key"])
			"fonts":
				add_item(asset["key"])
			"misc":
				add_item(asset["key"])
