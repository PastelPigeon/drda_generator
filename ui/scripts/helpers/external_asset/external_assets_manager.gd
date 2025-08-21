extends Node

## 资产类型
enum AssetType {
	CHARACTER_FACES,
	CHARACTER_SOUNDS,
	DIALOGUE_TEXTURES,
	FONTS,
	MISC
}

## 资产子文件夹名称
const ASSET_DIR_NAMES = [
	"character_faces",
	"character_sounds",
	"dialogue_textures",
	"fonts",
	"misc"
]

## 外置资产清单文件键名
const EXTERNAL_ASSETS_MANIFEST_KEY_NAMES = [
	"character_faces",
	"character_sounds",
	"dialogue_textures",
	"fonts",
	"misc"
]

## 资产类型与资产子文件夹名称映射表
const ASSET_TYPE_ASSET_DIR_NAMES_MAPPING = {
	AssetType.CHARACTER_FACES: ASSET_DIR_NAMES[0],
	AssetType.CHARACTER_SOUNDS: ASSET_DIR_NAMES[1],
	AssetType.DIALOGUE_TEXTURES: ASSET_DIR_NAMES[2],
	AssetType.FONTS: ASSET_DIR_NAMES[3],
	AssetType.MISC: ASSET_DIR_NAMES[4],
}

## 资产类型与外置资产清单文件键名映射表
const ASSET_TYPE_EXTERNAL_ASSETS_MANIFEST_KEY_NAMES_MAPPING = {
	AssetType.CHARACTER_FACES: EXTERNAL_ASSETS_MANIFEST_KEY_NAMES[0],
	AssetType.CHARACTER_SOUNDS: EXTERNAL_ASSETS_MANIFEST_KEY_NAMES[1],
	AssetType.DIALOGUE_TEXTURES: EXTERNAL_ASSETS_MANIFEST_KEY_NAMES[2],
	AssetType.FONTS: EXTERNAL_ASSETS_MANIFEST_KEY_NAMES[3],
	AssetType.MISC: EXTERNAL_ASSETS_MANIFEST_KEY_NAMES[4],
}

## 外置资产文件夹
const EXTERNAL_ASSETS_DIR = "user://external_assets"

## 初始化
func init():
	# 创建外置资产文件夹
	DirAccess.make_dir_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR))
	
	# 创建资产子文件夹及注册文件
	for asset_dir_name in ASSET_DIR_NAMES:
		# 创建子文件夹
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path("%s/%s" % [EXTERNAL_ASSETS_DIR, asset_dir_name]))
		
		# 创建注册文件
		var registry_file = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, asset_dir_name, "registry.json"], FileAccess.WRITE)
		registry_file.store_string(JSON.stringify({}))
		registry_file.close()
		
	# 初始化清单文件内容
	var manifest = {}
	
	# 生成清单文件内容
	for manifest_key in EXTERNAL_ASSETS_MANIFEST_KEY_NAMES:
		manifest[manifest_key] = ProjectSettings.globalize_path("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[ASSET_TYPE_EXTERNAL_ASSETS_MANIFEST_KEY_NAMES_MAPPING.find_key(manifest_key)], "registry.json"])
		
	# 创建并写入清单文件
	var manifest_file = FileAccess.open("%s/%s" % [EXTERNAL_ASSETS_DIR, "manifest.json"], FileAccess.WRITE)
	manifest_file.store_string(JSON.stringify(manifest, "	"))
	manifest_file.close()
	
## 添加键
func add_key(type: AssetType, key: String):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 添加键
	registry[key] = []
	
	# 重新保存注册文件
	var registry_file_write = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.WRITE)
	registry_file_write.store_string(JSON.stringify(registry, "	"))
	registry_file_write.close()
	
## 移除键
func remove_key(type: AssetType, key: String):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 删除键
	registry.erase(key)
	
	# 重新保存注册文件
	var registry_file_write = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.WRITE)
	registry_file_write.store_string(JSON.stringify(registry, "	"))
	registry_file_write.close()
	
## 重命名键
func rename_key(type: AssetType, key: String, new_name: String):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 以新名称添加键
	registry[new_name] = registry[key]
	
	# 删除键
	registry.erase(key)
	
	# 重新保存注册文件
	var registry_file_write = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.WRITE)
	registry_file_write.store_string(JSON.stringify(registry, "	"))
	registry_file_write.close()
	
## 添加资产
func add_asset(type: AssetType, key: String, file: String):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定文件是否存在，不存在直接返回
	if FileAccess.file_exists(file) == false:
		return
		
	# 复制文件
	DirAccess.copy_absolute(file, ProjectSettings.globalize_path("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], file.get_file()]))
	
	# 修改注册文件
	registry[key].append(ProjectSettings.globalize_path("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], file.get_file()]))
	
	# 重新保存注册文件
	var registry_file_write = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.WRITE)
	registry_file_write.store_string(JSON.stringify(registry, "	"))
	registry_file_write.close()
	
	# 如果类型为CHARACTER_SOUNDS，初始化资产属性
	if type == AssetType.CHARACTER_SOUNDS:
		set_asset_attribute_CHARACTER_SOUNDS(key, registry[key].find(ProjectSettings.globalize_path("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], file.get_file()])), 1, 1.0)
		
	# 如果类型为DIALOGUE_TEXTURES，初始化资产属性
	if type == AssetType.DIALOGUE_TEXTURES:
		set_asset_attribute_DIALOGUE_TEXTURES(key, registry[key].find(ProjectSettings.globalize_path("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], file.get_file()])), 1, "all")
	
		
## 移除资产
func remove_asset(type: AssetType, key: String, index: int):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 删除文件
	DirAccess.remove_absolute(registry[key][index])
	
	# 修改注册文件
	registry[key].remove_at(index)
	
	# 重新保存注册文件
	var registry_file_write = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.WRITE)
	registry_file_write.store_string(JSON.stringify(registry, "	"))
	registry_file_write.close()
	
## 重命名资产
func rename_asset(type: AssetType, key: String, index: int, new_name: String):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 重命名文件
	DirAccess.rename_absolute(registry[key][index], "%s/%s.%s" % [registry[key][index].get_base_dir(), new_name, registry[key][index].get_extension()])
	
	# 修改注册文件
	registry[key][index] = "%s/%s.%s" % [registry[key][index].get_base_dir(), new_name, registry[key][index].get_extension()]
	
	# 重新保存注册文件
	var registry_file_write = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.WRITE)
	registry_file_write.store_string(JSON.stringify(registry, "	"))
	registry_file_write.close()
	
## 设置资产属性（CHARACTER_SOUNDS）
func set_asset_attribute_CHARACTER_SOUNDS(key: String, index: int, sound_timer: int, random_pitch: float):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[AssetType.CHARACTER_SOUNDS], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 重命名指定资产
	rename_asset(AssetType.CHARACTER_SOUNDS, key, index, "%s@%s-%s" % [registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[0], str(sound_timer), str(random_pitch)])
	
## 设置资产属性（DIALOGUE_TEXTURES）
func set_asset_attribute_DIALOGUE_TEXTURES(key: String, index: int, next_texture_timer: int, text_animation_state: String):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[AssetType.DIALOGUE_TEXTURES], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 重命名指定资产
	rename_asset(AssetType.DIALOGUE_TEXTURES, key, index, "%s@%s-%s" % [registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[0], str(next_texture_timer), text_animation_state])
	
## 读取指定注册表
func get_registry(type: AssetType):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	return registry
	
## 获取资产信息
func get_asset_info(type: AssetType, key: String, index: int):
	match type:
		AssetType.CHARACTER_FACES:
			return _get_asset_info_CHARACTER_FACES(key, index)
		AssetType.CHARACTER_SOUNDS:
			return _get_asset_info_CHARACTER_SOUNDS(key, index)
		AssetType.DIALOGUE_TEXTURES:
			return _get_asset_info_DIALOGUE_TEXTURES(key, index)
		_:
			return _get_asset_info_DEFAULT(type, key, index)
	
## 获取资产信息（默认通用类型）
func _get_asset_info_DEFAULT(type: AssetType, key: String, index: int):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[type], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 获取资产路径
	var asset_path = registry[key][index]
	
	# 获取资产名称
	var asset_name = registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "")
	
	# 获取资产扩展名
	var asset_extension = registry[key][index].get_extension()
	
	# 获取资产大小
	var asset_file = FileAccess.open(registry[key][index], FileAccess.READ)
	var asset_length = asset_file.get_length()
	asset_file.close()
	
	return {
		"path": asset_path,
		"name": asset_name,
		"extension": asset_extension,
		"length": asset_length
	}
	
## 获取资产信息（CHARACTER_FACES类型）
func _get_asset_info_CHARACTER_FACES(key: String, index: int):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[AssetType.CHARACTER_FACES], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 获取资产路径
	var asset_path = registry[key][index]
	
	# 获取资产名称
	var asset_name = registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "")
	
	# 获取资产扩展名
	var asset_extension = registry[key][index].get_extension()
	
	# 获取资产大小
	var asset_file = FileAccess.open(registry[key][index], FileAccess.READ)
	var asset_length = asset_file.get_length()
	asset_file.close()
	
	# 获取脸图尺寸
	var loaded_asset = AssetLoader.load_asset(registry[key][index])
	var asset_size = [loaded_asset.get_image().get_width(), loaded_asset.get_image().get_height()]
	
	return {
		"path": asset_path,
		"name": asset_name,
		"extension": asset_extension,
		"length": asset_length,
		"size": asset_size
	}
	
## 获取资产信息（CHARACTER_SOUNDS类型）
func _get_asset_info_CHARACTER_SOUNDS(key: String, index: int):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[AssetType.CHARACTER_SOUNDS], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 获取资产路径
	var asset_path = registry[key][index]
	
	# 获取资产名称
	var asset_name = registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[0]
	
	# 获取资产扩展名
	var asset_extension = registry[key][index].get_extension()
	
	# 获取资产大小
	var asset_file = FileAccess.open(registry[key][index], FileAccess.READ)
	var asset_length = asset_file.get_length()
	asset_file.close()
	
	# 获取对话音效时长
	var loaded_asset = AssetLoader.load_asset(registry[key][index])
	var asset_duration = loaded_asset.get_length()
	
	# 获取sound_timer属性
	var asset_sound_timer = int(registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[1].split("-")[0])
	
	# 获取random_pitch属性
	var asset_random_pitch = float(registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[1].split("-")[1])
	
	return {
		"path": asset_path,
		"name": asset_name,
		"extension": asset_extension,
		"length": asset_length,
		"duration": asset_duration,
		"sound_timer": asset_sound_timer,
		"random_pitch": asset_random_pitch
	}
	
## 获取资产信息（DIALOGUE_TEXTURES类型）
func _get_asset_info_DIALOGUE_TEXTURES(key: String, index: int):
	# 判断是否初始化，未初始化先初始化
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(EXTERNAL_ASSETS_DIR)) == false:
		init()
		
	# 读取指定注册文件
	var registry_file_read = FileAccess.open("%s/%s/%s" % [EXTERNAL_ASSETS_DIR, ASSET_TYPE_ASSET_DIR_NAMES_MAPPING[AssetType.DIALOGUE_TEXTURES], "registry.json"], FileAccess.READ)
	var registry = JSON.parse_string(registry_file_read.get_as_text())
	registry_file_read.close()
	
	# 判断指定键是否存在，不存在直接返回
	if registry.has(key) == false:
		return
		
	# 判断指定索引是否存在，不存在直接返回
	if index < 0 or index > len(registry[key]) - 1:
		return
		
	# 获取资产路径
	var asset_path = registry[key][index]
	
	# 获取资产名称
	var asset_name = registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[0]
	
	# 获取资产扩展名
	var asset_extension = registry[key][index].get_extension()
	
	# 获取资产大小
	var asset_file = FileAccess.open(registry[key][index], FileAccess.READ)
	var asset_length = asset_file.get_length()
	asset_file.close()
	
	# 获取脸图尺寸
	var loaded_asset = AssetLoader.load_asset(registry[key][index])
	var asset_size = [loaded_asset.get_image().get_width(), loaded_asset.get_image().get_height()]
	
	# 获取纹理切换计时器
	var asset_next_texture_timer = int(registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[1].split("-")[0])
	
	# 获取文字动画状态
	var asset_text_animation_state = registry[key][index].get_file().replace(".%s" % registry[key][index].get_extension(), "").split("@")[1].split("-")[1]
	
	return {
		"path": asset_path,
		"name": asset_name,
		"extension": asset_extension,
		"length": asset_length,
		"size": asset_size,
		"next_texture_timer": asset_next_texture_timer,
		"text_animation_state": asset_text_animation_state
	}
