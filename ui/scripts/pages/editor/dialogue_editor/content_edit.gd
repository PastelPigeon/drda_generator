extends CodeEdit

# 自定义信号：当选中内容改变或光标移动（且无选中）时触发
# 未选中内容时，start_char_index 和 end_char_index 均为当前光标位置
signal selection_changed(start_char_index, end_char_index)

# 存储上一帧的选中起始、结束位置以及光标位置，用于比较
var _last_selection_from_line: int = -1
var _last_selection_from_column: int = -1
var _last_selection_to_line: int = -1
var _last_selection_to_column: int = -1
var _last_caret_column: int = -1
var _last_caret_line: int = -1

# 存储start_char_index与end_char_index
var _start_char_index = 0
var _end_char_index = 0

# 新增：用于存储失去焦点前的选区状态
var _stored_selection_from_line: int = -1
var _stored_selection_from_column: int = -1
var _stored_selection_to_line: int = -1
var _stored_selection_to_column: int = -1
var _stored_start_char_index: int = -1  # 新增：失去焦点前的起始字符索引
var _stored_end_char_index: int = -1    # 新增：失去焦点前的结束字符索引
var _is_focused: bool = false

# 新增：用于在选区变化时立即存储字符索引
var _current_start_char_index: int = 0
var _current_end_char_index: int = 0

func _ready() -> void:
	# 连接信号
	EditorDialoguesManager.dialogues_changed.connect(_on_dialogues_changed)
	EditorDialoguesManager.selected_dialogue_id_changed.connect(_on_selected_dialogue_id_changed)
	text_changed.connect(_on_text_changed)
	owner.quick_insertion_menu.quick_insertion_menu_insert_button_pressed.connect(_on_quick_insertion_menu_insert_button_pressed)
	
	# 新增：连接焦点信号
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	_update_last_state()
	
func _process(_delta):
	# 只在有焦点时检查选区变化
	if _is_focused and _has_selection_or_caret_moved():
		# 获取当前的选中范围
		var current_selection_from_line = get_selection_from_line()
		var current_selection_from_column = get_selection_from_column()
		var current_selection_to_line = get_selection_to_line()
		var current_selection_to_column = get_selection_to_column()

		# 判断是否有选中文本
		if has_selection():
			# 有选中内容，发射信号，参数为选中起始和结束位置
			var from_absolute_index = _get_absolute_char_index(current_selection_from_line, current_selection_from_column)
			var to_absolute_index = _get_absolute_char_index(current_selection_to_line, current_selection_to_column)
			emit_signal("selection_changed", from_absolute_index, to_absolute_index)
			
			_start_char_index = from_absolute_index
			_end_char_index = to_absolute_index
			
			# 新增：立即存储当前选区字符索引
			_current_start_char_index = from_absolute_index
			_current_end_char_index = to_absolute_index
		else:
			# 没有选中内容，获取当前光标位置（行和列）
			var caret_line = get_caret_line()
			var caret_column = get_caret_column()
			# 将行和列转换为绝对字符索引（需要考虑换行符）
			var absolute_index = _get_absolute_char_index(caret_line, caret_column)
			# 未选中时，起始和结束索引都为光标位置
			emit_signal("selection_changed", absolute_index, absolute_index)
			
			_start_char_index = absolute_index
			_end_char_index = absolute_index
			
			# 新增：立即存储当前光标位置字符索引
			_current_start_char_index = absolute_index
			_current_end_char_index = absolute_index

		# 更新上一次的状态
		_update_last_state()

# 新增：焦点进入处理
func _on_focus_entered():
	_is_focused = true
	# 焦点回来时，尝试恢复之前存储的选区
	if (_stored_selection_from_line != -1 and _stored_selection_from_column != -1 and
		_stored_selection_to_line != -1 and _stored_selection_to_column != -1):
		
		# 使用正确的select方法参数
		select(_stored_selection_from_line, _stored_selection_from_column, 
			  _stored_selection_to_line, _stored_selection_to_column)
		
		# 恢复后重置存储值
		_stored_selection_from_line = -1
		_stored_selection_from_column = -1
		_stored_selection_to_line = -1
		_stored_selection_to_column = -1
		_stored_start_char_index = -1
		_stored_end_char_index = -1

# 新增：焦点退出处理
func _on_focus_exited():
	_is_focused = false
	# 失去焦点前，保存当前选区状态
	if has_selection():
		_stored_selection_from_line = get_selection_from_line()
		_stored_selection_from_column = get_selection_from_column()
		_stored_selection_to_line = get_selection_to_line()
		_stored_selection_to_column = get_selection_to_column()
		
		# 新增：保存字符索引（使用实时存储的值）
		_stored_start_char_index = _current_start_char_index
		_stored_end_char_index = _current_end_char_index
	else:
		# 如果没有选区，存储光标位置
		_stored_selection_from_line = get_caret_line()
		_stored_selection_from_column = get_caret_column()
		_stored_selection_to_line = get_caret_line()
		_stored_selection_to_column = get_caret_column()
		
		# 新增：保存字符索引（使用实时存储的值）
		_stored_start_char_index = _current_start_char_index
		_stored_end_char_index = _current_end_char_index

# 新增：获取失去焦点前的起始字符索引
func get_stored_start_char_index() -> int:
	return _stored_start_char_index

# 新增：获取失去焦点前的结束字符索引
func get_stored_end_char_index() -> int:
	return _stored_end_char_index

# 新增：获取当前起始字符索引
func get_current_start_char_index() -> int:
	return _current_start_char_index

# 新增：获取当前结束字符索引
func get_current_end_char_index() -> int:
	return _current_end_char_index

# 新增：检查是否有存储的选区信息
func has_stored_selection() -> bool:
	return _stored_start_char_index != -1 and _stored_end_char_index != -1

# 检查选中区域或光标位置是否发生变化
func _has_selection_or_caret_moved() -> bool:
	var current_selection_from_line = get_selection_from_line()
	var current_selection_from_column = get_selection_from_column()
	var current_selection_to_line = get_selection_to_line()
	var current_selection_to_column = get_selection_to_column()
	var current_caret_line = get_caret_line()
	var current_caret_column = get_caret_column()

	# 比较当前和上一次的选中起始、结束位置以及光标行和列
	if (current_selection_from_line != _last_selection_from_line or
		current_selection_from_column != _last_selection_from_column or
		current_selection_to_line != _last_selection_to_line or
		current_selection_to_column != _last_selection_to_column or
		current_caret_line != _last_caret_line or
		current_caret_column != _last_caret_column):
		return true
	return false

# 更新上一次记录的选中状态和光标位置
func _update_last_state():
	_last_selection_from_line = get_selection_from_line()
	_last_selection_from_column = get_selection_from_column()
	_last_selection_to_line = get_selection_to_line()
	_last_selection_to_column = get_selection_to_column()
	_last_caret_line = get_caret_line()
	_last_caret_column = get_caret_column()

# 将一个 (行, 列) 位置转换为绝对的字符索引（考虑换行符）
# 这是一个简单的实现，假设每行都没有自动换行
func _get_absolute_char_index(line: int, column: int) -> int:
	var total_chars: int = 0
	# 遍历到指定行之前的所有行
	for i in range(line):
		total_chars += get_line(i).length() + 1 # +1 用于换行符
	# 加上指定行的列数
	total_chars += column
	return total_chars

## 当文本变化时执行
func _on_text_changed():
	# 判断指定对话项在dialogues数组中是否存在，不存在直接返回，不进行下一步操作
	if len(EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == EditorDialoguesManager.selected_dialogue_id)) == 0:
		return
	
	# 更新对话项内容
	EditorDialoguesManager.set_dialogue_content(EditorDialoguesManager.selected_dialogue_id, EditorBbcodeParser.complete_bbcode_string_end_tags(text))
	
## 当dialogues变化时触发
func _on_dialogues_changed(type: EditorDialoguesManager.DialoguesChangedType):
	pass
	
## 当selected_dialogue_id变化时执行
func _on_selected_dialogue_id_changed():
	_update_ui()

## 更新ui
func _update_ui():
	# 判断指定对话项在dialogues数组中是否存在，不存在直接返回，不进行下一步操作
	if len(EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == EditorDialoguesManager.selected_dialogue_id)) == 0:
		return
		
	# 获取选中对话内容
	var content = EditorDialoguesManager.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == EditorDialoguesManager.selected_dialogue_id)[0]["content"]
	
	# 将文本设为对话内容
	text = content
	
func _unhandled_input(event: InputEvent) -> void:
	# 处理快捷输入
	if event.is_action_pressed("ui_editor_dialogue_editor_content_edit_insert_en_font"):
		# 快速插入英文字体样式
		insert_text_at_caret("[font=res://assets/fonts/dtm.tres][font_size=48]")
	elif event.is_action_pressed("ui_editor_dialogue_editor_content_edit_insert_zh_font"):
		# 快速插入中文字体样式
		insert_text_at_caret("[font=res://assets/fonts/fzb.tres][font_size=48]")
	elif event.is_action_pressed("ui_editor_dialogue_editor_content_edit_insert_world_state_dark"):
		# 快速插入暗世界对话框样式
		insert_text_at_caret("[world_state=dark]")
		
## 当快速插入菜单插入按钮点下时执行
func _on_quick_insertion_menu_insert_button_pressed(quick_insertion_id: String, options: Dictionary):
	# 获取快速插入信息
	var quick_insertion_info = QuickInsertionsManager.get_quick_insertion_info(quick_insertion_id)
	
	# 判断当为包裹型标签时，选中是否合法，不合法直接返回
	if quick_insertion_info["type"] == "wrappered":
		# 使用当前存储的字符索引而不是失去焦点前的
		if _stored_start_char_index == _stored_end_char_index:
			return
	
	# 判断当为自闭合型标签时，选中是否合法，不合法直接返回
	if quick_insertion_info["type"] == "closed":
		# 使用当前存储的字符索引而不是失去焦点前的
		if _stored_start_char_index != _stored_end_char_index:
			return
			
	# 根据不同类型的标签选取不同的插入方式
	match  quick_insertion_info["type"]:
		"wrappered":
			# 包裹型 - 使用当前存储的字符索引
			text = "%s%s%s" % [text.substr(0, _stored_start_char_index), quick_insertion_info["replacement"].format(DictionaryMerger.merge_dictionaries([options, {"text": text.substr(_stored_start_char_index, _stored_end_char_index - _stored_start_char_index)}])), text.substr(_stored_end_char_index)]
		"closed":
			# 自闭合型
			insert_text_at_caret(quick_insertion_info["replacement"].format(options))
			
	# 手动发送信号
	text_changed.emit()
