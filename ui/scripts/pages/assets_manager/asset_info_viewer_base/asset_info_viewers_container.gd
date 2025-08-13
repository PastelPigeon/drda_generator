extends Control

## 查看器类型
enum ViewerType{
	CHARACTER_FACES,
	CHARACTER_SOUNDS,
	DIALOGUE_TEXTURES,
	DEFAULT,
	KEY,
	NONE
}

## 资产类型与查看器类型映射表
const ASSET_TYPE_VIEWER_TYPE_MAPPING = {
	ExternalAssetsManager.AssetType.CHARACTER_FACES: ViewerType.CHARACTER_FACES,
	ExternalAssetsManager.AssetType.CHARACTER_SOUNDS: ViewerType.CHARACTER_SOUNDS,
	ExternalAssetsManager.AssetType.DIALOGUE_TEXTURES: ViewerType.DIALOGUE_TEXTURES,
	ExternalAssetsManager.AssetType.FONTS: ViewerType.DEFAULT,
	ExternalAssetsManager.AssetType.MISC: ViewerType.DEFAULT,
}

## 已经注册的查看器
const REGISTERED_VIEWERS = [
	{
		"type": ViewerType.CHARACTER_FACES,
		"node": "AssetInfoViewerCharacterFaces"
	},
	{
		"type": ViewerType.CHARACTER_SOUNDS,
		"node": "AssetInfoViewerCharacterSounds"
	},
	{
		"type": ViewerType.DIALOGUE_TEXTURES,
		"node": "AssetInfoViewerDialogueTextures"
	},
	{
		"type": ViewerType.DEFAULT,
		"node": "AssetInfoViewerDefault"
	},
	{
		"type": ViewerType.KEY,
		"node": "AssetInfoViewerKey"
	},
	{
		"type": ViewerType.NONE,
		"node": "AssetInfoViewerNone"
	}
]

func _ready() -> void:
	# 连接信号
	AssetsManagerDataManager.selected_key_changed.connect(_update_ui)
	AssetsManagerDataManager.selected_index_changed.connect(_update_ui)
	
	# 手动更新ui
	_update_ui()

## 更新ui
func _update_ui():
	# 隐藏所有查看器
	for viewer in get_children():
		viewer.visible = false
		
	# 根据key和index判断应该显示的查看器
	if AssetsManagerDataManager.selected_key == "" and AssetsManagerDataManager.selected_index == -1:
		# 未选中任何内容
		get_node(REGISTERED_VIEWERS.filter(func (info): return info["type"] == ViewerType.NONE)[0]["node"]).visible = true
	elif AssetsManagerDataManager.selected_key != "" and AssetsManagerDataManager.selected_index == -1:
		# 选中键
		get_node(REGISTERED_VIEWERS.filter(func (info): return info["type"] == ViewerType.KEY)[0]["node"]).visible = true
	else:
		# 选中资产项
		get_node(REGISTERED_VIEWERS.filter(func (info): return info["type"] == ASSET_TYPE_VIEWER_TYPE_MAPPING[AssetsManagerDataManager.selected_asset_type])[0]["node"]).visible = true
