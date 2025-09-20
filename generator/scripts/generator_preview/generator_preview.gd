extends Control

## 动画名称
const ANIMATION_NAME = "preview_animation_library/preview_animation"

signal animation_player_playing_changed ## 动画播放状态改变时发出
signal animation_player_current_animation_position_changed ## 动画播放时长改变时发出
signal canplay_state_changed ## 能否播放状态改变时发出

var animation_player_playing: bool: ## 动画播放状态
	set(value):
		# 判断值是否与先前相同，相同直接返回
		if value == animation_player_playing:
			return
			
		# 设置值
		animation_player_playing = value
		
		# 发送信号
		animation_player_playing_changed.emit()
		
var animation_player_current_animation_position: float: ## 动画播放时长
	set(value):
		# 判断值是否与先前相同，相同直接返回
		if value == animation_player_current_animation_position:
			return
			
		# 设置值
		animation_player_current_animation_position = value
		
		# 发送信号
		animation_player_current_animation_position_changed.emit()
		
var canplay_state: bool: ## 能否播放状态
	set(value):
		# 判断值是否与先前相同，相同直接返回
		if value == canplay_state:
			return
			
		# 设置值
		canplay_state = value
		
		# 发送信号
		canplay_state_changed.emit()
		
func _ready() -> void:
	# 重置所有状态
	reset()
		
func _process(delta: float) -> void:
	# 轮询更新状态
	_update_animation_player_states()
	_update_canplay_state()
		
## 更新AnimationPlayer相关状态
func _update_animation_player_states():
	# 更新动画播放状态
	animation_player_playing = %AnimationPlayer.is_playing()
	
	# 更新动画播放时长状态
	if %AnimationPlayer.has_animation(ANIMATION_NAME) and %AnimationPlayer.current_animation != "":
		animation_player_current_animation_position = %AnimationPlayer.current_animation_position
		
## 更新能否播放状态
func _update_canplay_state():
	# 获取判断条件
	var canplay_condition = %AnimationPlayer.has_animation(ANIMATION_NAME)
	
	# 根据判断条件设置能否播放状态的值
	match canplay_condition:
		true:
			canplay_state = true
		false:
			canplay_state = false
			
## 设置动画播放状态
func set_animation_player_playing(playing: bool):
	# 获取能否播放状态，无法播放时直接返回
	if get_canplay_state() == false:
		return
		
	# 根据传入的播放状态控制AnimationPlayer播放或暂停
	match playing:
		true:
			%AnimationPlayer.play(ANIMATION_NAME)
		false:
			%AnimationPlayer.pause()
			
	# 手动更新一次内部状态
	animation_player_playing = playing
			
## 获取动画播放状态
func get_animation_player_playing():
	return animation_player_playing
	
## 设置动画播放时长
func set_animation_player_current_animation_position(animation_position: float):
	# 获取能否播放状态，无法播放时直接返回
	if get_canplay_state() == false:
		return
		
	# 判断给定时长是否超出了总时长，超出直接返回
	if animation_position < 0 or animation_position > %AnimationPlayer.get_animation(ANIMATION_NAME).length:
		return
		
	# 控制AnimationPlayer跳转到指定时长
	%AnimationPlayer.seek(animation_position, true)
		
	# 手动更新一次内部状态
	animation_player_current_animation_position = animation_position
	
## 获取动画播放时长
func get_animation_player_current_animation_position():
	return animation_player_current_animation_position
	
## 上一帧
func previous_frame():
	# 跳转至上一帧的时长
	set_animation_player_current_animation_position(animation_player_current_animation_position - %AnimationPlayer.get_animation(ANIMATION_NAME).step)
	
## 下一帧
func next_frame():
	# 跳转至下一帧的时长
	set_animation_player_current_animation_position(animation_player_current_animation_position + %AnimationPlayer.get_animation(ANIMATION_NAME).step)
	
## 跳转至开头
func to_start():
	# 跳转至开头时长
	set_animation_player_current_animation_position(0)
	
## 跳转至结尾
func to_end():
	# 跳转至结尾时长
	set_animation_player_current_animation_position(%AnimationPlayer.get_animation(ANIMATION_NAME).length)

## 获取能否播放状态
func get_canplay_state():
	return canplay_state
	
## 更新预览动画
func update_preview_animation(dialogues: Array, options: Dictionary):
	# 重置所有状态
	reset()
	
	# 生成预览动画
	var preview_animation = AnimationGenerator.generate_animation_preview(dialogues, options)
	
	# 将预览动画添加到动画库
	var preview_animation_library = AnimationLibrary.new()
	preview_animation_library.add_animation(ANIMATION_NAME.split("/")[1], preview_animation)
	
	# 将动画库添加到AnimationPlayer
	%AnimationPlayer.add_animation_library(ANIMATION_NAME.split("/")[0], preview_animation_library)
	
## 获取预览动画
func get_preview_animation():
	# 判断动画是否存在与AnimationPlayer中，不存在直接返回
	if %AnimationPlayer.has_animation(ANIMATION_NAME) == false:
		return 
	
	return %AnimationPlayer.get_animation(ANIMATION_NAME)
	
## 重置所有状态
func reset():
	# 判断AnimationPlayer中是否有动画，如果有，则清除
	if %AnimationPlayer.has_animation(ANIMATION_NAME):
		# 清除AnimationPlayer中的动画
		%AnimationPlayer.remove_animation_library(ANIMATION_NAME.split("/")[0])
	
	# 重置内部状态
	animation_player_playing = false
	animation_player_current_animation_position = 0
	canplay_state = false
