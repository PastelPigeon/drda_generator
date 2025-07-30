extends Panel

var _is_dragging = false ## 判断是否正在拖拽窗口
var _click_pos = Vector2i.ZERO ## 鼠标拖拽位置

func _input(event: InputEvent) -> void:
	# 应用内弹窗不执行任何操作
	if owner.is_dialog:
		return
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			if self.get_rect().has_point(event.position):
				# 设置鼠标点击位置
				_click_pos = Vector2i(event.position)
				
				# 设置拖拽状态
				_is_dragging = true
		elif event.is_released():
			# 松开鼠标时停止拖拽
			_is_dragging = false
			
			
func _process(delta: float) -> void:
	if _is_dragging:
		# 处于拖拽状态下更新窗口坐标
		DisplayServer.window_set_position(DisplayServer.mouse_get_position() - _click_pos)
