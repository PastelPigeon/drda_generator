extends Control

## 已经注册的页面
const REGISTERED_PAGES = [
	{
		"index": 0,
		"node": "Editor"
	},
	{
		"index": 1,
		"node": "OptionsManager"
	},
	{
		"index": 2,
		"node": "AssetsManager"
	},
	{
		"index": 3,
		"node": "About"
	},
	{
		"index": 4,
		"node": "Doc"
	}
]

func _ready() -> void:
	# 连接信号
	owner.current_page_index_changed.connect(_on_current_page_index_changed)

## 当选中的页面索引变化时执行
func _on_current_page_index_changed():
	# 将所有页面设为不可见
	for page in get_children():
		page.visible = false
		
	# 判断选中的页面序号是否在已经注册的页面数组中存在，不存在直接返回，不进行下一步操作
	if len(REGISTERED_PAGES.filter(func (page): return page["index"] == owner.current_page_index)) == 0:
		return
		
	# 将选中的页面节点设为可见
	get_node(REGISTERED_PAGES.filter(func (page): return page["index"] == owner.current_page_index)[0]["node"]).visible = true
