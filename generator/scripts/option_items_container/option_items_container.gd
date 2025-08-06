extends ColorRect

var loaded_options: Array: ## 已加载的options数组
	set(value):
		# 设置loaded_options
		loaded_options = value
		
		# 加载布局文件
		var layouts = _get_options_layout()
		
		# 判断给定的options是否有对应的布局，没有直接返回
		if len(layouts.filter(func (layout): return layout["count"] == len(loaded_options))) == 0:
			return
			
		# 加载指定布局
		var layout = layouts.filter(func (layout): return layout["count"] == len(loaded_options))[0]
		
		# 遍历指定布局，设置OptionItem
		for option_item_index in range(len(layout["option_items"])):
			# 获取指定节点
			var option_item = get_node("MarginContainer/Control/OptionItem%s" % str(option_item_index))
			
			# 判断节点是否启用
			if layout["option_items"][option_item_index] != -1:
				# 当布局信息存储的option_index不为-1时，代表该option_item启用
				option_item.visible = true # 设置可见性
				option_item.text = loaded_options[layout["option_items"][option_item_index]] # 设置文本
				option_item.selected = false # 设置未选中
			else:
				# 当布局信息存储的option_index为-1时，代表该option_item禁用
				option_item.visible = false # 设置可见性
				option_item.text = "" # 设置文本
				option_item.selected = false # 设置未选中
				
		# 处理layout-defualt_select
		select_option(layout["default_select"])
		
var selected_option_index: int: ## 已选中的属性索引
	set(value):
		# 设置selected_option_index
		selected_option_index = value
		
		# 加载布局文件
		var layouts = _get_options_layout()
		
		# 判断给定的options是否有对应的布局，没有直接返回
		if len(layouts.filter(func (layout): return layout["count"] == len(loaded_options))) == 0:
			return
			
		# 加载指定布局
		var layout = layouts.filter(func (layout): return layout["count"] == len(loaded_options))[0]
		
		# 判断给定的option_index是否存在在loaded_options上，不存在直接返回（不包含-1特殊值）
		if selected_option_index > len(loaded_options) - 1 or selected_option_index < 0:
			if selected_option_index != -1:
				return
				
		# 判断给定的option_index是否存在在布局上，不存在直接返回（不包含-1特殊值）
		if len(layout["option_items"].filter(func (option_index): return option_index == selected_option_index)) == 0 and selected_option_index != -1:
			return
			
		# 将所有的OptionItem设为未选中状态
		for option_item_index in range(len(layout["option_items"])):
			# 获取指定节点
			var option_item = get_node("MarginContainer/Control/OptionItem%s" % str(option_item_index))
			option_item.selected = false
			
		# 判断selected_option_index是否为特殊值-1
		if selected_option_index != -1:
			# 隐藏PlaceholderSoulContainer
			%PlaceholderSoulContainer.visible = false
			
			# 获取指定节点，并将其设为选中状态
			var option_item = get_node("MarginContainer/Control/OptionItem%s" % str(range(len(layout["option_items"])).filter(func (option_item_index): return layout["option_items"][option_item_index] == selected_option_index)[0]))
			option_item.selected = true
		else:
			# 显示PlaceholderSoulContainer
			%PlaceholderSoulContainer.visible = true
			
func _ready() -> void:
	# 初始化
	load_options([])
	select_option(-1)
			
## 加载选项
func load_options(options: Array):
	loaded_options = options
	
## 选中指定选项
func select_option(option_index: int):
	selected_option_index = option_index

## 读取options_layout
func _get_options_layout():
	var options_layout_path = AssetFinder.find_asset(AssetFinder.AssetType.MISC, "options_layout")[0]
	var options_layout_file = FileAccess.open(options_layout_path, FileAccess.READ)
	var options_layout = JSON.parse_string(options_layout_file.get_as_text())
	options_layout_file.close()
	
	return options_layout
