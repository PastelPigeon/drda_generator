extends Node

signal assets_viewer_assets_tree_updating_needed ## 当assets_viewer页面的assets_tree控件需要更新时手动发出
signal selected_asset_type_changed ## 当selected_asset_type变化时发出
signal selected_key_changed ## 当selected_key变化时发出
signal selected_index_changed ## 当selected_index变化时发出

var selected_asset_type: ExternalAssetsManager.AssetType: ## 当前正在编辑的资产类型
	set(value):
		selected_asset_type = value
		selected_asset_type_changed.emit()
		
		# 设置selected_key与selected_index
		selected_key = ""
		selected_index = -1
		
var selected_key: String: ## 当前选中的键（空字符串为未选中）
	set(value):
		selected_key = value
		selected_key_changed.emit()
		
var selected_index: int: ## 当前选中的资产索引（-1为未选中）
	set(value):
		selected_index = value
		selected_index_changed.emit()
		
func _init() -> void:
	# 初始化
	selected_asset_type = ExternalAssetsManager.AssetType.CHARACTER_FACES
	selected_key = ""
	selected_index = -1
