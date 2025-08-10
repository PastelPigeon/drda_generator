extends Node

## 存储所有内置资源注册文件路径
const REGISTRY_PATHS = [
	"res://assets/character_faces/registry.json",
	"res://assets/character_sounds/registry.json",
	"res://assets/dialogue_textures/registry.json",
	"res://assets/fonts/registry.json",
	"res://assets/misc/registry.json"
]

## 外置资源清单文件键名与内置资源注册文件路径映射表
const EXTERNAL_ASSETS_MANIFEST_KEY_NAMES_REGISTRY_PATHS_MAPPING = {
	"character_faces": "res://assets/character_faces/registry.json",
	"character_sounds": "res://assets/character_sounds/registry.json",
	"dialogue_textures": "res://assets/dialogue_textures/registry.json",
	"fonts": "res://assets/fonts/registry.json",
	"misc": "res://assets/misc/registry.json",
}

## 运行时资源注册表存储路径
const RUNTIME_REGISTRIES_DIR = "user://runtime_registries"

## 创建运行时资源注册表
func create_runtime_registries(external_assets_manifest: String = ""):
	# 创建RUNTIME_REGISTRIES_DIR
	DirAccess.make_dir_absolute(ProjectSettings.globalize_path(RUNTIME_REGISTRIES_DIR))
	
	# 遍历REGISTRY_PATHS，创建运行时资源注册表
	for registry_path in REGISTRY_PATHS:
		# 读取内置资源注册表
		var registry_file = FileAccess.open(registry_path, FileAccess.READ)
		var registry = registry_file.get_as_text()
		registry_file.close()
		
		# 创建运行时资源注册表
		var runtime_registry_file = FileAccess.open(RUNTIME_REGISTRIES_DIR.path_join("registry@%s.json" % registry_path.split("/")[len(registry_path.split("/")) - 2]), FileAccess.WRITE)
		runtime_registry_file.store_string(registry)
		runtime_registry_file.close()
		
	# 判断external_assets_manifest是否无效（为空字符串或指向不存在的文件），无效直接返回，不进行下一步操作
	if external_assets_manifest == "" or FileAccess.file_exists(external_assets_manifest) == false:
		return
		
	# 读取external_assets_manifest
	var manifest_file = FileAccess.open(external_assets_manifest, FileAccess.READ)
	var manifest = JSON.parse_string(manifest_file.get_as_text())
	manifest_file.close()
	
	# 遍历manifest键
	for manifest_key in manifest.keys():
		# 判断manifest键是否在映射表中，不在直接跳过
		if EXTERNAL_ASSETS_MANIFEST_KEY_NAMES_REGISTRY_PATHS_MAPPING.has(manifest_key) == false:
			continue
			
		# 判断项指向的注册文件是否存在，不存在直接跳过
		if FileAccess.file_exists(manifest[manifest_key]) == false:
			continue
			
		# 读取内置资源注册表
		var internal_registry_file = FileAccess.open(EXTERNAL_ASSETS_MANIFEST_KEY_NAMES_REGISTRY_PATHS_MAPPING[manifest_key], FileAccess.READ)
		var internal_registry = JSON.parse_string(internal_registry_file.get_as_text())
		internal_registry_file.close()
		
		# 读取外置资源注册表
		var external_registry_file = FileAccess.open(manifest[manifest_key], FileAccess.READ)
		var external_registry = JSON.parse_string(external_registry_file.get_as_text())
		external_registry_file.close()
		
		# 合并内置资源注册表与外置资源注册表
		var new_registry = DictionaryMerger.merge_dictionaries(
			[
				internal_registry,
				external_registry
			]
		)
		
		# 写入运行时注册表
		var runtime_registry_file = FileAccess.open(RUNTIME_REGISTRIES_DIR.path_join("registry@%s.json" % EXTERNAL_ASSETS_MANIFEST_KEY_NAMES_REGISTRY_PATHS_MAPPING[manifest_key].split("/")[len(EXTERNAL_ASSETS_MANIFEST_KEY_NAMES_REGISTRY_PATHS_MAPPING[manifest_key].split("/")) - 2]), FileAccess.WRITE)
		runtime_registry_file.store_string(JSON.stringify(new_registry, "	"))
		runtime_registry_file.close()
		
func _enter_tree() -> void:
	# 退出时删除RUNTIME_REGISTRIES_DIR
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RUNTIME_REGISTRIES_DIR))
