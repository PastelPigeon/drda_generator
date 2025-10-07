extends Node

# 录制状态
enum RecordingState {
	IDLE,
	RECORDING
}

# 输出格式枚举
enum RecordingFormat {
	MP4,    # 标准MP4格式（带音频）
	MOV,    # QuickTime格式（支持透明背景）
	GIF     # GIF动画格式（支持透明背景）
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
	var start_time: float  # 开始时间戳
	var frame_times: Array[float] = []  # 记录每帧的实际时间
	var last_frame_image: Image  # 存储上一帧图像用于补帧

var _state: RecordingState = RecordingState.IDLE
var _current_recording: RecordingInfo = null
var _recordings: Dictionary = {}
var _frame_timer: float = 0.0
var _target_fps: float = 30.0
var _global_output_dir: String = "user://recordings"
var _master_bus_index: int = 0  # 主总线索引
var _record_effect_index: int = -1  # 录制效果在总线中的位置
var _time_since_last_frame: float = 0.0  # 跟踪帧间时间
var _thread: Thread  # 用于多线程处理
var _should_thread_exit: bool = false  # 线程退出标志
var _frame_queue: Array = []  # 帧队列，用于线程间通信
var _frame_queue_mutex: Mutex  # 保护帧队列的互斥锁

func _ready() -> void:
	# 初始化互斥锁
	_frame_queue_mutex = Mutex.new()
	
	# 自动初始化音频录制
	initialize_audio_recording()
	
	# 设置默认帧率
	Engine.max_fps = 0  # 不限制最大FPS
	
	# 启动处理线程
	_thread = Thread.new()
	_thread.start(_thread_process)

# 线程处理函数
func _thread_process() -> void:
	while not _should_thread_exit:
		# 检查队列中是否有帧需要处理
		_frame_queue_mutex.lock()
		var queue_size = _frame_queue.size()
		if queue_size > 0:
			var frame_data = _frame_queue.pop_front()
			_frame_queue_mutex.unlock()
			
			# 处理帧数据
			_process_frame_data(frame_data)
		else:
			_frame_queue_mutex.unlock()
			# 队列为空，短暂休眠避免占用过多CPU
			OS.delay_usec(5000)  # 休眠5ms

# 处理帧数据（在子线程中执行）
func _process_frame_data(frame_data: Dictionary) -> void:
	var img: Image = frame_data.image
	var frame_path: String = frame_data.path
	var frame_time: float = frame_data.time
	
	# 保存帧
	var error = img.save_png(frame_path)
	if error != OK:
		push_error("Failed to save frame: " + frame_path)
		return
	
	# 记录帧时间（如果提供了）
	if frame_data.has("recording") and frame_data.recording != null:
		_frame_queue_mutex.lock()
		frame_data.recording.frame_times.append(frame_time)
		_frame_queue_mutex.unlock()

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
	_capture_frame(true)
	
	return true

# 捕获一帧
# is_actual_frame: 是否为实际捕获的帧（false表示补帧）
func _capture_frame(is_actual_frame: bool = true) -> void:
	if _state != RecordingState.RECORDING:
		return
	
	var current_time = Time.get_ticks_usec() / 1000000.0
	var elapsed_time = current_time - _current_recording.start_time
	
	# 获取或创建图像
	var img: Image
	if is_actual_frame:
		# 获取视口图像
		var viewport = get_viewport()
		if not viewport:
			push_error("No viewport available!")
			return
		
		# 捕获视频帧
		img = viewport.get_texture().get_image()
		if not img:
			push_error("Failed to capture viewport image!")
			return
		
		# 保存当前帧用于可能的补帧
		_current_recording.last_frame_image = img
	else:
		# 使用上一帧图像进行补帧
		if _current_recording.last_frame_image:
			img = _current_recording.last_frame_image.duplicate()
		else:
			# 没有上一帧可用，跳过
			return
	
	# 准备帧数据
	var frame_path = "%sframe_%08d.png" % [_current_recording.frames_path, _current_recording.frame_count]
	var frame_data = {
		"image": img,
		"path": frame_path,
		"time": elapsed_time,
		"recording": _current_recording if is_actual_frame else null
	}
	
	# 将帧数据添加到队列（线程安全）
	_frame_queue_mutex.lock()
	_frame_queue.append(frame_data)
	_frame_queue_mutex.unlock()
	
	_current_recording.frame_count += 1
	
	# 每30帧打印一次状态
	if _current_recording.frame_count % 30 == 0:
		var actual_fps = _current_recording.frame_count / elapsed_time
		print("Frames: %d, Actual FPS: %.1f (Target: %d)" % [_current_recording.frame_count, actual_fps, _target_fps])

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
		# 计算需要补多少帧
		var frames_to_capture = floor(_time_since_last_frame / target_frame_interval)
		
		# 捕获实际帧
		_capture_frame(true)
		
		# 补帧
		for i in range(1, frames_to_capture):
			_capture_frame(false)
		
		# 调整时间计数器，考虑补帧
		_time_since_last_frame -= frames_to_capture * target_frame_interval

# 停止录制并返回ID
func stop_recording() -> String:
	if _state != RecordingState.RECORDING:
		push_error("Not recording!")
		return ""
	
	_state = RecordingState.IDLE
	set_process(false)
	
	# 等待所有帧处理完成
	while _frame_queue.size() > 0:
		OS.delay_usec(10000)  # 等待10ms
	
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

# 保存指定录制为指定格式
func save_recordings(recording_ids: Array, format: RecordingFormat = RecordingFormat.MP4, transparent_color = null) -> Dictionary:
	var results = {}
	
	for id in recording_ids:
		if not _recordings.has(id):
			results[id] = {"success": false, "message": "Recording not found"}
			continue
		
		var recording = _recordings[id]
		results[id] = _convert_recording(recording, format, transparent_color)
	
	return results
	
## 保存所有录制
func save_all_recordings(format: RecordingFormat = RecordingFormat.MP4, transparent_color = null):
	# 保存录制
	save_recordings(get_all_recording_ids(), format, transparent_color)
	
	# 删除缓存数据
	for recording_id in get_all_recording_ids():
		clean_temp_frames(recording_id)

# 内部方法：转换录制内容为指定格式
func _convert_recording(recording: RecordingInfo, format: RecordingFormat = RecordingFormat.MP4, transparent_color = null) -> Dictionary:
	# 获取FFmpeg路径 - 使用绝对路径
	var ffmpeg_path = ""
	
	# 处理不同平台的路径
	match OS.get_name():
		"Windows":
			ffmpeg_path = ProjectSettings.globalize_path("res://externals/ffmpeg.exe")
		"macOS", "Linux":
			ffmpeg_path = ProjectSettings.globalize_path("res://externals/ffmpeg")
			if not FileAccess.file_exists(ffmpeg_path):
				var env_path = OS.get_environment("PATH").split(":")
				for path_item in env_path:
					if FileAccess.file_exists(path_item.path_join("ffmpeg")):
						ffmpeg_path = path_item.path_join("ffmpeg")
						break
				return {
					"success": false,
					"message": "Failed to find ffmpeg in PATH. Make sure you installed it through package manager!",
					"output_path": ""
				}
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
	
	# 根据格式确定文件扩展名
	var file_extension = ""
	match format:
		RecordingFormat.MP4:
			file_extension = "mp4"
		RecordingFormat.MOV:
			file_extension = "mov"
		RecordingFormat.GIF:
			file_extension = "gif"
	
	# 输出文件路径
	var output_path = "%s/%s.%s" % [output_dir, recording.created_at, file_extension]
	
	# 构建FFmpeg命令 - 确保所有路径都是绝对路径
	var input_path = ProjectSettings.globalize_path(recording.frames_path + "frame_%08d.png")
	var audio_path = ProjectSettings.globalize_path(recording.audio_file)
	var absolute_output_path = ProjectSettings.globalize_path(output_path)
	
	# 检查音频文件是否存在
	var has_audio = FileAccess.file_exists(audio_path) && format != RecordingFormat.GIF
	
	# 构建FFmpeg命令
	var args = ["-y"]  # 覆盖现有文件
	
	# 添加输入帧序列
	args.append_array([
		"-framerate", str(recording.fps),
		"-i", input_path
	])
	
	# 添加音频输入（如果存在且格式支持音频）
	if has_audio:
		args.append_array(["-i", audio_path])
	
	# 处理透明颜色（如果指定）
	var transparency_filter = ""
	if transparent_color != null:
		# 将Godot颜色转换为FFmpeg颜色格式 (0xRRGGBB)
		var hex_color = "#%02x%02x%02x" % [
			int(transparent_color.r8),
			int(transparent_color.g8),
			int(transparent_color.b8)
		]
		
		# 创建颜色键滤镜 - 使用与MOV相同的参数
		transparency_filter = "colorkey=%s:0.3:0.1" % hex_color
	
	# 根据格式添加特定参数
	match format:
		RecordingFormat.MP4:
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
					"-af", "aresample=async=1:first_pts=0",  # 音频同步处理
					"-vsync", "vfr",  # 使用可变帧率
					"-shortest"  # 确保视频长度与音频一致
				])
			else:
				args.append_array(["-an", "-vsync", "vfr"])  # 无音频 + 可变帧率
			
			# 如果指定了透明色，添加颜色键滤镜
			if transparency_filter != "":
				args.append_array(["-vf", transparency_filter])
		
		RecordingFormat.MOV:
			# 支持透明背景的ProRes编码
			args.append_array([
				"-c:v", "prores_ks",
				"-profile:v", "4",  # ProRes 4444 (支持Alpha通道)
				"-pix_fmt", "yuva444p10le",  # 支持Alpha通道的像素格式
				"-vendor", "apl0",  # Apple ProRes四字符代码
				"-qscale:v", "9"  # 质量级别（1-31，值越低质量越高）
			])
			
			# 添加音频编码参数（如果存在）
			if has_audio:
				args.append_array([
					"-c:a", "pcm_s16le",  # MOV格式常用无损音频编码
					"-af", "aresample=async=1:first_pts=0",  # 音频同步处理
					"-vsync", "vfr",  # 使用可变帧率
					"-shortest"  # 确保视频长度与音频一致
				])
			else:
				args.append_array(["-an", "-vsync", "vfr"])  # 无音频 + 可变帧率
			
			# 如果指定了透明色，添加颜色键滤镜
			if transparency_filter != "":
				args.append_array(["-vf", transparency_filter])
		
		RecordingFormat.GIF:
			# GIF编码参数（无音频）
			args.append_array(["-an"])  # 无音频
			
			# 基础GIF滤镜链
			var gif_filter = "fps=%d" % recording.fps
			
			# 如果指定了透明色，添加到滤镜链
			if transparency_filter != "":
				gif_filter += "," + transparency_filter
			
			# 确保透明背景正确处理
			gif_filter += ",split[s0][s1];[s0]palettegen=reserve_transparent=1:transparency_color=ffffff[p];[s1][p]paletteuse=alpha_threshold=128"
			
			args.append_array([
				"-vf", gif_filter,
				"-loop", "0",  # 无限循环
				"-gifflags", "+transdiff",  # 优化透明帧
				"-vsync", "vfr"  # 使用可变帧率
			])
	
	# 添加输出路径
	args.append(absolute_output_path)
	
	# 打印调试信息
	print("Executing FFmpeg: ", ffmpeg_path, " ", " ".join(args))
	
	# 执行FFmpeg
	var output = []
	var exit_code = OS.execute(ffmpeg_path, args, output, true)
	
	if exit_code != 0:
		print("damn")
		var error_msg = "FFmpeg failed with code: %d\n" % exit_code
		for line in output:
			error_msg += line + "\n"
		return {
			"success": false,
			"message": error_msg,
			"output_path": ""
		}
	print("nmad")
	return {
		"success": true,
		"message": "%s saved successfully" % file_extension.to_upper(),
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
	# 停止录制线程
	_should_thread_exit = true
	if _thread and _thread.is_started():
		_thread.wait_to_finish()
	
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

# 获取当前录制状态
func is_recording() -> bool:
	return _state == RecordingState.RECORDING

# 获取当前录制ID
func get_current_recording_id() -> String:
	if _current_recording:
		return _current_recording.id
	return ""
