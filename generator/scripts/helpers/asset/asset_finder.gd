extends Node

## 资产类型
enum AssetType {
	CHARACTER_FACES,
	CHARACTER_SOUNDS,
	DIALOGUE_TEXTURES,
	FONTS,
	MISC
}

## 运行时资源注册表存储路径
const RUNTIME_REGISTRIES_DIR = "user://runtime_registries"

## 从资产类型和资产键名查找资产路径（未查找到资产时返回空Array）
func find_asset(asset_type: AssetType, asset_key_name: String) -> Array:
	# 从给定的资产类型获取资产registry路径
	var registry_path = ""
	
	match asset_type:
		AssetType.CHARACTER_FACES:
			registry_path = RUNTIME_REGISTRIES_DIR.path_join("registry@%s.json" % "character_faces")
		AssetType.CHARACTER_SOUNDS:
			registry_path = RUNTIME_REGISTRIES_DIR.path_join("registry@%s.json" % "character_sounds")
		AssetType.DIALOGUE_TEXTURES:
			registry_path = RUNTIME_REGISTRIES_DIR.path_join("registry@%s.json" % "dialogue_textures")
		AssetType.FONTS:
			registry_path = RUNTIME_REGISTRIES_DIR.path_join("registry@%s.json" % "fonts")
		AssetType.MISC:
			registry_path = RUNTIME_REGISTRIES_DIR.path_join("registry@%s.json" % "misc")
		_:
			# 资产类型未查找到时直接返回空Array
			return []
			
	# 读取registry
	var registry_file_access = FileAccess.open(registry_path, FileAccess.READ)
	var registry_content = JSON.parse_string(registry_file_access.get_as_text())
	registry_file_access.close()
	
	# 返回值
	if registry_content.has(asset_key_name):
		return registry_content[asset_key_name]
	else:
		# 未查找到资产时返回空Array
		return []
	
