extends Node

# 录制状态
enum RecordingState {
	IDLE,
	RECORDING
}

# 录制信息结构
class RecordingInfo:
	var id: String
	var frames_path: String
	var frame_count: int
	var fps: float
	var created_at: String
	var output_dir: String
	var audio_file: String
	var audio_effect_record: AudioEffectRecord
	var audio_bus_index: int
	var start_time: float  # 添加开始时间戳
	var frame_times: Array[float] = []  # 记录每帧的实际时间

var _state: RecordingState = RecordingState.IDLE
var _current_recording: RecordingInfo = null
var _recordings: Dictionary = {}
var _frame_timer: float = 0.0
var _target_fps: float = 30.0
var _global_output_dir: String = "user://recordings"
var _master_bus_index: int = 0  # 主总线索引
var _record_effect_index: int = -1  # 录制效果在总线中的位置
var _time_since_last_frame: float = 0.0  # 跟踪帧间时间

func _ready() -> void:
	# 自动初始化音频录制
	initialize_audio_recording()
	
	# 设置默认帧率
	Engine.max_fps = 0  # 不限制最大FPS

# 设置全局输出目录
func set_output_dir(dir: String) -> void:
	if not dir.ends_with("/"):
		dir += "/"
	_global_output_dir = dir
	DirAccess.make_dir_recursive_absolute(_global_output_dir)
	print("Output directory set to: ", _global_output_dir)

# 初始化音频录制
func initialize_audio_recording() -> bool:
	# 检查是否已在主总线添加录制效果
	if _record_effect_index != -1:
		return true
	
	# 创建音频录制效果
	var record_effect = AudioEffectRecord.new()
	
	# 添加到主总线
	_record_effect_index = AudioServer.get_bus_effect_count(_master_bus_index)
	AudioServer.add_bus_effect(_master_bus_index, record_effect)
	AudioServer.set_bus_effect_enabled(_master_bus_index, _record_effect_index, true)
	
	print("Audio recording initialized on Master bus")
	return true

# 开始录制
func start_recording(fps: float = 30.0, custom_output_dir: String = "") -> bool:
	if _state != RecordingState.IDLE:
		push_error("Already recording!")
		return false
	
	# 确保音频系统已初始化
	if not initialize_audio_recording():
		push_error("Failed to initialize audio recording!")
		return false
	
	_target_fps = fps
	
	# 创建唯一ID和时间戳
	var recording_id = "rec_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000)
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	
	# 设置帧存储路径
	var frames_dir = _global_output_dir.path_join("%s/%s/" % [recording_id, timestamp])
	DirAccess.make_dir_recursive_absolute(frames_dir)
	
	# 设置音频文件路径
	var audio_path = frames_dir + "audio.wav"
	
	# 创建录制信息
	_current_recording = RecordingInfo.new()
	_current_recording.id = recording_id
	_current_recording.frames_path = frames_dir
	_current_recording.frame_count = 0
	_current_recording.fps = fps
	_current_recording.created_at = timestamp
	_current_recording.output_dir = custom_output_dir if custom_output_dir else _global_output_dir
	_current_recording.audio_file = audio_path
	_current_recording.audio_bus_index = _master_bus_index
	_current_recording.start_time = Time.get_ticks_usec() / 1000000.0  # 记录精确开始时间
	
	# 获取音频录制效果
	var record_effect = AudioServer.get_bus_effect(_master_bus_index, _record_effect_index) as AudioEffectRecord
	if record_effect:
		_current_recording.audio_effect_record = record_effect
		record_effect.set_recording_active(true)
		print("Audio recording started on Master bus")
	else:
		push_error("Failed to get audio recording effect!")
		return false
	
	# 重置帧计时器
	_frame_timer = 0.0
	_time_since_last_frame = 0.0
	_state = RecordingState.RECORDING
	
	print("Recording started. ID: ", recording_id)
	print("Frames will be stored in: ", frames_dir)
	print("Target FPS: ", fps)
	set_process(true)
	
	# 立即捕获第一帧
	_capture_frame()
	
	return true

# 捕获一帧
func _capture_frame():
	if _state != RecordingState.RECORDING:
		return
	
	# 记录当前帧的时间戳
	var current_time = Time.get_ticks_usec() / 1000000.0
	_current_recording.frame_times.append(current_time - _current_recording.start_time)
	
	# 获取视口图像
	var viewport = get_viewport()
	if not viewport:
		push_error("No viewport available!")
		return
	
	# 捕获视频帧
	var img = viewport.get_texture().get_image()
	if not img:
		push_error("Failed to capture viewport image!")
		return
	
	# 保存帧
	var frame_path = "%sframe_%08d.png" % [_current_recording.frames_path, _current_recording.frame_count]
	var error = img.save_png(frame_path)
	if error != OK:
		push_error("Failed to save frame: %d" % _current_recording.frame_count)
		return
	
	_current_recording.frame_count += 1

# 自动处理帧捕获
func _process(delta):
	if _state != RecordingState.RECORDING:
		return
	
	_time_since_last_frame += delta
	_frame_timer += delta
	
	# 计算目标帧间隔
	var target_frame_interval = 1.0 / _target_fps
	
	# 如果距离上一帧的时间已经超过目标间隔，捕获新帧
	if _time_since_last_frame >= target_frame_interval:
		_capture_frame()
		_time_since_last_frame = 0.0  # 重置计时器
		
		# 计算实际帧率
		var actual_fps = 1.0 / (_frame_timer / _current_recording.frame_count)
		if _current_recording.frame_count % 30 == 0:  # 每30帧打印一次
			print("Actual FPS: %.1f (Target: %d)" % [actual_fps, _target_fps])

# 停止录制并返回ID
func stop_recording() -> String:
	if _state != RecordingState.RECORDING:
		push_error("Not recording!")
		return ""
	
	_state = RecordingState.IDLE
	set_process(false)
	
	# 停止音频录制
	if _current_recording.audio_effect_record:
		_current_recording.audio_effect_record.set_recording_active(false)
		print("Audio recording stopped")
		
		# 获取录制的音频流
		var audio_stream = _current_recording.audio_effect_record.get_recording()
		if audio_stream:
			# 保存音频文件
			var error = audio_stream.save_to_wav(_current_recording.audio_file)
			if error != OK:
				push_error("Failed to save audio file: " + _current_recording.audio_file)
			else:
				print("Audio saved: " + _current_recording.audio_file)
		else:
			push_error("No audio recording available")
	
	# 保存录制信息
	_recordings[_current_recording.id] = _current_recording
	var recording_id = _current_recording.id
	_current_recording = null
	
	print("Recording stopped. ID: ", recording_id)
	print("Captured frames: ", _recordings[recording_id].frame_count)
	return recording_id

# 保存指定录制为MP4（带音频）
func save_recordings(recording_ids: Array) -> Dictionary:
	var results = {}
	
	for id in recording_ids:
		if not _recordings.has(id):
			results[id] = {"success": false, "message": "Recording not found"}
			continue
		
		var recording = _recordings[id]
		results[id] = _convert_to_mp4(recording)
	
	return results
	
## 保存所有录制
func save_all_recordings():
	# 保存录制
	save_recordings(get_all_recording_ids())
	
	# 删除缓存数据
	for recording_id in get_all_recording_ids():
		clean_temp_frames(recording_id)

# 内部方法：使用FFmpeg转换（带音频）
func _convert_to_mp4(recording: RecordingInfo) -> Dictionary:
	# 获取FFmpeg路径 - 使用绝对路径
	var ffmpeg_path = ""
	
	# 处理不同平台的路径
	match OS.get_name():
		"Windows":
			ffmpeg_path = ProjectSettings.globalize_path("res://externals/ffmpeg.exe")
		"macOS", "Linux":
			ffmpeg_path = ProjectSettings.globalize_path("res://externals/ffmpeg")
		_:
			return {
				"success": false,
				"message": "Unsupported platform: " + OS.get_name(),
				"output_path": ""
			}
	
	# 检查FFmpeg是否存在
	if not FileAccess.file_exists(ffmpeg_path):
		return {
			"success": false,
			"message": "FFmpeg not found at: " + ffmpeg_path,
			"output_path": ""
		}
	
	var output_dir = recording.output_dir if recording.output_dir != "" else _global_output_dir
	
	if (!DirAccess.dir_exists_absolute(output_dir)):
		DirAccess.make_dir_recursive_absolute(output_dir)
	
	# 输出文件路径
	var output_path = "%s/%s.mp4" % [output_dir, recording.created_at]
	
	# 构建FFmpeg命令 - 确保所有路径都是绝对路径
	var input_path = ProjectSettings.globalize_path(recording.frames_path + "frame_%08d.png")
	var audio_path = ProjectSettings.globalize_path(recording.audio_file)
	var absolute_output_path = ProjectSettings.globalize_path(output_path)
	
	# 检查音频文件是否存在
	var has_audio = FileAccess.file_exists(audio_path)
	
	# 构建FFmpeg命令
	var args = [
		"-y",  # 覆盖现有文件
		"-framerate", str(recording.fps),
		"-i", input_path
	]
	
	# 添加音频输入（如果存在）
	if has_audio:
		args.append_array(["-i", audio_path])
	
	# 添加视频编码参数
	args.append_array([
		"-c:v", "libx264",
		"-pix_fmt", "yuv420p",
		"-crf", "18"  # 中等质量
	])
	
	# 添加音频编码参数（如果存在）
	if has_audio:
		args.append_array([
			"-c:a", "aac",
			"-b:a", "192k",
			"-af", "aresample=async=1:first_pts=0",  # 添加音频同步处理
			"-vsync", "vfr",  # 使用可变帧率
			"-shortest"  # 确保视频长度与音频一致
		])
	else:
		args.append_array(["-an", "-vsync", "vfr"])  # 无音频 + 可变帧率
	
	# 添加输出路径
	args.append(absolute_output_path)
	
	# 打印调试信息
	print("Executing FFmpeg: ", ffmpeg_path, " ", " ".join(args))
	
	# 执行FFmpeg
	var output = []
	var exit_code = OS.execute(ffmpeg_path, args, output, true)
	
	if exit_code != 0:
		var error_msg = "FFmpeg failed with code: %d\n" % exit_code
		for line in output:
			error_msg += line + "\n"
		return {
			"success": false,
			"message": error_msg,
			"output_path": ""
		}
	
	return {
		"success": true,
		"message": "Video saved successfully" + (" with audio" if has_audio else " without audio"),
		"output_path": absolute_output_path
	}

# 获取所有录制ID
func get_all_recording_ids() -> Array:
	return _recordings.keys()

# 清理临时帧数据和音频文件
func clean_temp_frames(recording_id: String) -> bool:
	if not _recordings.has(recording_id):
		return false
	
	var recording = _recordings[recording_id]
	var dir = DirAccess.open(recording.frames_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = recording.frames_path.path_join(file_name)
			if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".wav")):
				dir.remove(full_path)
			file_name = dir.get_next()
		
		# 删除空目录
		DirAccess.remove_absolute(recording.frames_path)
	
	return true

# 获取录制信息
func get_recording_info(recording_id: String) -> Dictionary:
	if not _recordings.has(recording_id):
		return {}
	
	var info = _recordings[recording_id]
	return {
		"id": info.id,
		"frame_count": info.frame_count,
		"fps": info.fps,
		"created_at": info.created_at,
		"frames_path": info.frames_path,
		"output_dir": info.output_dir,
		"has_audio": FileAccess.file_exists(info.audio_file) if info else false
	}

# 当节点退出场景时清理
func _exit_tree():
	if _state == RecordingState.RECORDING:
		var id = stop_recording()
		print("Recording aborted: ", id)

# 获取当前全局输出目录
func get_output_dir() -> String:
	return _global_output_dir

# 复制FFmpeg到可访问位置
func copy_ffmpeg_to_user_dir() -> bool:
	var source_path = "res://externals/ffmpeg.exe"
	var target_dir = "user://externals/"
	var target_path = target_dir.path_join("ffmpeg.exe")
	
	# 确保目标目录存在
	DirAccess.make_dir_recursive_absolute(target_dir)
	
	# 如果目标文件已存在，则跳过
	if FileAccess.file_exists(target_path):
		return true
	
	# 复制文件
	var error = DirAccess.copy_absolute(source_path, target_path)
	if error != OK:
		push_error("Failed to copy FFmpeg to user directory: Error %d" % error)
		return false
	
	print("FFmpeg copied to: ", ProjectSettings.globalize_path(target_path))
	return true

# 确保所有音频都路由到主总线
func ensure_audio_routing_to_master():
	# 所有音频播放器默认路由到主总线
	# 此函数确保没有音频被错误路由
	pass

# 调试音频系统
func debug_audio_system():
	print("Audio buses:")
	for i in range(AudioServer.bus_count):
		print("Bus ", i, ": ", AudioServer.get_bus_name(i))
		print("  Volume: ", AudioServer.get_bus_volume_db(i), " dB")
		
		print("  Effects:")
		for j in range(AudioServer.get_bus_effect_count(i)):
			var effect = AudioServer.get_bus_effect(i, j)
			print("    ", j, ": ", effect.resource_name if effect else "None")
	
	print("\nMaster bus effects:")
	for j in range(AudioServer.get_bus_effect_count(_master_bus_index)):
		var effect = AudioServer.get_bus_effect(_master_bus_index, j)
		print("  ", j, ": ", effect.get_class())
	
	print("\nRecording effect index: ", _record_effect_index)
	

# 计算实际帧率
func calculate_actual_fps(recording_id: String) -> float:
	if not _recordings.has(recording_id):
		return 0.0
	
	var recording = _recordings[recording_id]
	if recording.frame_count < 2:
		return 0.0
	
	# 计算总时间和平均帧间隔
	var total_time = recording.frame_times.back() - recording.frame_times.front()
	return (recording.frame_count - 1) / total_time
