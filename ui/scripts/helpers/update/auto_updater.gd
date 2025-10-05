# auto_updater.gd
extends Node

# 常量定义
const REPO_OWNER: String = "PastelPigeon"
const REPO_NAME: String = "drda_generator"
const ASSET_NAME: String = "drda_generator_dist.zip"  # 已更新为实际资源包名称

# 可用镜像列表（按优先级排序）
const AVAILABLE_MIRRORS: Array[String] = [
	"",  # 空字符串表示官方GitHub
	"https://ghproxy.com",
	"https://mirror.ghproxy.com", 
	"https://github.moeyy.xyz",
	"https://ghps.cc",
	"https://gh.ddlc.top"
]

# 发布信息结构体
class ReleaseInfo:
	var tag_name: String
	var name: String
	var body: String
	var published_at: String
	var html_url: String
	var assets: Array
	
	func _init():
		tag_name = ""
		name = ""
		body = ""
		published_at = ""
		html_url = ""
		assets = []

# 私有变量
var _current_mirror_index: int = 0
var _is_checking: bool = false
var _current_http_request: HTTPRequest = null

# 信号定义
signal update_available(latest_version: String, current_version: String)
signal no_update_available(current_version: String)
signal update_check_failed(error_message: String)
signal update_started()
signal update_completed()
signal update_failed(error_message: String)
signal release_info_loaded(release_info: ReleaseInfo)  # 新增：发布信息加载完成信号
signal release_info_failed(error_message: String)      # 新增：发布信息加载失败信号

# 单例实例
static var instance: AutoUpdater

func _init():
	if instance == null:
		instance = self
	else:
		push_error("AutoUpdater 已经存在实例，不能创建多个单例")
		queue_free()

# 检查是否存在可用更新
func check_update() -> bool:
	if _is_checking:
		push_warning("AutoUpdater: 更新检查正在进行中")
		return false
	
	_is_checking = true
	_current_mirror_index = 0
	
	# 开始检查更新流程
	_check_update_with_current_mirror()
	return true

# 使用当前镜像检查更新
func _check_update_with_current_mirror():
	var url = _build_api_url("/repos/" + REPO_OWNER + "/" + REPO_NAME + "/releases/latest")
	
	print("AutoUpdater: 正在检查更新，URL: ", url)
	
	# 清理之前的请求
	if _current_http_request and is_instance_valid(_current_http_request):
		_current_http_request.queue_free()
		_current_http_request = null
	
	# 创建新的HTTP请求
	_current_http_request = HTTPRequest.new()
	add_child(_current_http_request)
	_current_http_request.request_completed.connect(_on_http_request_completed)
	
	# 设置User-Agent头，避免GitHub API限制:cite[1]
	var headers = ["User-Agent: GodotAutoUpdater/1.0"]
	var error = _current_http_request.request(url, headers)
	if error != OK:
		_handle_request_error(error, "创建HTTP请求失败")

# 构建API URL
func _build_api_url(api_path: String) -> String:
	var mirror = AVAILABLE_MIRRORS[_current_mirror_index]
	
	if mirror == "":
		# 官方GitHub:cite[1]
		return "https://api.github.com" + api_path
	else:
		# 镜像服务 - 使用正确的URL结构
		return mirror + "/https://api.github.com" + api_path

# 处理HTTP请求完成
func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	_is_checking = false
	
	# 清理HTTP请求
	if _current_http_request and is_instance_valid(_current_http_request):
		_current_http_request.queue_free()
		_current_http_request = null
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("AutoUpdater: 请求失败，结果代码: ", result, " (", _get_result_string(result), ")")
		_try_next_mirror()
		return
	
	if response_code != 200:
		print("AutoUpdater: HTTP错误: ", response_code)
		# 如果是GitHub API限制，尝试下一个镜像
		if response_code == 403 or response_code == 429:
			_try_next_mirror()
		else:
			update_check_failed.emit("HTTP错误: " + str(response_code))
		return
	
	# 解析响应
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response == null:
		print("AutoUpdater: JSON解析失败")
		_try_next_mirror()
		return
	
	if not response.has("tag_name"):
		print("AutoUpdater: 响应中缺少tag_name字段")
		_try_next_mirror()
		return
	
	var latest_version = response["tag_name"]
	var current_version = _get_current_version()
	
	# 清理版本号（移除可能的'v'前缀）
	latest_version = latest_version.trim_prefix("v")
	current_version = current_version.trim_prefix("v")
	
	print("AutoUpdater: 当前版本: ", current_version, "，最新版本: ", latest_version)
	
	if _is_newer_version(latest_version, current_version):
		update_available.emit(latest_version, current_version)
	else:
		no_update_available.emit(current_version)

# 获取HTTP请求结果的可读字符串
func _get_result_string(result: int) -> String:
	match result:
		HTTPRequest.RESULT_SUCCESS: return "成功"
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH: return "分块正文大小不匹配"
		HTTPRequest.RESULT_CANT_CONNECT: return "无法连接"
		HTTPRequest.RESULT_CANT_RESOLVE: return "无法解析主机"
		HTTPRequest.RESULT_CONNECTION_ERROR: return "连接错误"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR: return "TLS握手错误"
		HTTPRequest.RESULT_NO_RESPONSE: return "无响应"
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED: return "正文大小超过限制"
		HTTPRequest.RESULT_REQUEST_FAILED: return "请求失败"
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN: return "无法打开下载文件"
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR: return "下载文件写入错误"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED: return "重定向次数过多"
		HTTPRequest.RESULT_TIMEOUT: return "超时"
		_: return "未知错误"

# 尝试下一个镜像
func _try_next_mirror():
	_current_mirror_index += 1
	
	if _current_mirror_index < AVAILABLE_MIRRORS.size():
		print("AutoUpdater: 尝试下一个镜像: ", AVAILABLE_MIRRORS[_current_mirror_index])
		_check_update_with_current_mirror()
	else:
		# 所有镜像都尝试过了，检查失败
		update_check_failed.emit("所有镜像源都无法访问，请检查网络连接")

# 获取当前项目版本
func _get_current_version() -> String:
	return ProjectSettings.get_setting("application/config/version", "1.0.0")

# 比较版本号，判断是否有新版本
func _is_newer_version(latest: String, current: String) -> bool:
	var latest_parts = latest.split(".")
	var current_parts = current.split(".")
	
	# 确保两个版本号有相同数量的部分
	var max_parts = max(latest_parts.size(), current_parts.size())
	
	for i in range(max_parts):
		var latest_num = int(latest_parts[i]) if i < latest_parts.size() else 0
		var current_num = int(current_parts[i]) if i < current_parts.size() else 0
		
		if latest_num > current_num:
			return true
		elif latest_num < current_num:
			return false
	
	return false  # 版本相同

# 处理请求错误
func _handle_request_error(error: int, context: String):
	_is_checking = false
	var error_msg = context + " (错误代码: " + str(error) + ")"
	push_error("AutoUpdater: " + error_msg)
	
	# 清理HTTP请求
	if _current_http_request and is_instance_valid(_current_http_request):
		_current_http_request.queue_free()
		_current_http_request = null
	
	update_check_failed.emit(error_msg)

# 执行更新
func update():
	print("AutoUpdater: 开始更新流程...")
	update_started.emit()
	
	# 获取当前使用的镜像
	var selected_mirror = ""
	if _current_mirror_index < AVAILABLE_MIRRORS.size():
		selected_mirror = AVAILABLE_MIRRORS[_current_mirror_index]
	
	# 调用外部PowerShell脚本
	_execute_update_script(selected_mirror)

# 执行更新脚本
func _execute_update_script(mirror: String):
	var script_path = "res://externals/AutoUpdater.ps1"
	
	# 检查脚本是否存在
	if not FileAccess.file_exists(script_path):
		var error_msg = "更新脚本不存在: " + script_path
		push_error("AutoUpdater: " + error_msg)
		update_failed.emit(error_msg)
		return
	
	# 构建参数
	var args = [
		"-ExecutionPolicy", "Bypass",
		"-File", ProjectSettings.globalize_path(script_path),
		"-RepoOwner", REPO_OWNER,
		"-RepoName", REPO_NAME, 
		"-AssetName", ASSET_NAME,
		"-TargetPID", str(OS.get_process_id())
	]
	
	# 添加镜像参数（如果有且不是官方GitHub）
	if mirror != "":
		args.append("-Mirror")
		args.append(mirror)
	
	print("AutoUpdater: 执行PowerShell脚本，参数: ", args)
	
	# 执行PowerShell脚本
	var output = []
	var exit_code = OS.execute("powershell.exe", args, output, true)
	
	if exit_code == 0:
		print("AutoUpdater: 更新脚本执行成功")
		update_completed.emit()
	else:
		var error_msg = "更新脚本执行失败，退出代码: " + str(exit_code)
		if output.size() > 0:
			error_msg += "\n输出: " + str(output)
		push_error("AutoUpdater: " + error_msg)
		update_failed.emit(error_msg)

# 获取最新发布信息:cite[1]
func get_latest_release_info() -> bool:
	if _is_checking:
		push_warning("AutoUpdater: 正在执行其他请求，请稍后再试")
		return false
	
	_is_checking = true
	_current_mirror_index = 0
	
	# 开始获取发布信息流程
	_get_release_info_with_current_mirror()
	return true

# 使用当前镜像获取发布信息
func _get_release_info_with_current_mirror():
	var url = _build_api_url("/repos/" + REPO_OWNER + "/" + REPO_NAME + "/releases/latest")
	
	print("AutoUpdater: 正在获取发布信息，URL: ", url)
	
	# 清理之前的请求
	if _current_http_request and is_instance_valid(_current_http_request):
		_current_http_request.queue_free()
		_current_http_request = null
	
	# 创建新的HTTP请求
	_current_http_request = HTTPRequest.new()
	add_child(_current_http_request)
	_current_http_request.request_completed.connect(_on_release_info_request_completed)
	
	# 设置User-Agent头，避免GitHub API限制
	var headers = ["User-Agent: GodotAutoUpdater/1.0"]
	var error = _current_http_request.request(url, headers)
	if error != OK:
		_handle_release_info_error(error, "创建发布信息请求失败")

# 处理发布信息请求完成
func _on_release_info_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	_is_checking = false
	
	# 清理HTTP请求
	if _current_http_request and is_instance_valid(_current_http_request):
		_current_http_request.queue_free()
		_current_http_request = null
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("AutoUpdater: 发布信息请求失败，结果代码: ", result)
		_try_next_mirror_for_release_info()
		return
	
	if response_code != 200:
		print("AutoUpdater: 发布信息HTTP错误: ", response_code)
		# 如果是GitHub API限制，尝试下一个镜像
		if response_code == 403 or response_code == 429:
			_try_next_mirror_for_release_info()
		else:
			release_info_failed.emit("获取发布信息失败，HTTP错误: " + str(response_code))
		return
	
	# 解析响应
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response == null:
		print("AutoUpdater: 发布信息JSON解析失败")
		release_info_failed.emit("无法解析发布信息响应")
		return
	
	# 创建ReleaseInfo对象并填充数据
	var release_info = ReleaseInfo.new()
	release_info.tag_name = response.get("tag_name", "")
	release_info.name = response.get("name", "")
	release_info.body = response.get("body", "")
	release_info.published_at = response.get("published_at", "")
	release_info.html_url = response.get("html_url", "")
	release_info.assets = response.get("assets", [])
	
	print("AutoUpdater: 成功获取发布信息 - 版本: ", release_info.tag_name)
	release_info_loaded.emit(release_info)

# 尝试下一个镜像获取发布信息
func _try_next_mirror_for_release_info():
	_current_mirror_index += 1
	
	if _current_mirror_index < AVAILABLE_MIRRORS.size():
		print("AutoUpdater: 尝试下一个镜像获取发布信息: ", AVAILABLE_MIRRORS[_current_mirror_index])
		_get_release_info_with_current_mirror()
	else:
		# 所有镜像都尝试过了，获取失败
		release_info_failed.emit("所有镜像源都无法访问，无法获取发布信息")

# 处理发布信息请求错误
func _handle_release_info_error(error: int, context: String):
	_is_checking = false
	var error_msg = context + " (错误代码: " + str(error) + ")"
	push_error("AutoUpdater: " + error_msg)
	
	# 清理HTTP请求
	if _current_http_request and is_instance_valid(_current_http_request):
		_current_http_request.queue_free()
		_current_http_request = null
	
	release_info_failed.emit(error_msg)

# Markdown转BBCode函数:cite[2]:cite[5]
func markdown_to_bbcode(markdown: String) -> String:
	var bbcode := markdown
	
	# 转换标题 (# → [h1], ## → [h2]):cite[2]
	bbcode = bbcode.replace("[h1]", "").replace("[/h1]", "")  # 清理可能存在的旧标签
	bbcode = bbcode.replace("[h2]", "").replace("[/h2]", "")
	
	var header_regex = RegEx.new()
	
	# 转换h1标题
	header_regex.compile("^#\\s+(.+)$")
	bbcode = header_regex.sub(bbcode, "[h1]$1[/h1]", true)
	
	# 转换h2标题
	header_regex.compile("^##\\s+(.+)$")
	bbcode = header_regex.sub(bbcode, "[h2]$1[/h2]", true)
	
	# 转换h3标题
	header_regex.compile("^###\\s+(.+)$")
	bbcode = header_regex.sub(bbcode, "[h3]$1[/h3]", true)
	
	# 转换粗体 (**text** → [b]text[/b])
	header_regex.compile("\\*\\*(.+?)\\*\\*")
	bbcode = header_regex.sub(bbcode, "[b]$1[/b]", true)
	
	# 转换斜体 (*text* → [i]text[/i])
	header_regex.compile("\\*(.+?)\\*")
	bbcode = header_regex.sub(bbcode, "[i]$1[/i]", true)
	
	# 转换删除线 (~~text~~ → [s]text[/s])
	header_regex.compile("~~(.+?)~~")
	bbcode = header_regex.sub(bbcode, "[s]$1[/s]", true)
	
	# 转换链接 ([text](url) → [url=url]text[/url]):cite[5]
	header_regex.compile("\\[(.+?)\\]\\((.+?)\\)")
	bbcode = header_regex.sub(bbcode, "[url=$2]$1[/url]", true)
	
	# 转换图片 (![alt](src) → [img]src[/img])
	header_regex.compile("!\\[(.*?)\\]\\((.+?)\\)")
	bbcode = header_regex.sub(bbcode, "[img]$2[/img]", true)
	
	# 转换代码块 (```code``` → [code]code[/code])
	header_regex.compile("```(.*?)```")
	bbcode = header_regex.sub(bbcode, "[code]$1[/code]", true)
	
	# 转换内联代码 (`code` → [icode]code[/icode])
	header_regex.compile("`(.+?)`")
	bbcode = header_regex.sub(bbcode, "[icode]$1[/icode]", true)
	
	# 转换引用 (> text → [quote]text[/quote]):cite[2]
	header_regex.compile("^>\\s+(.+)$")
	bbcode = header_regex.sub(bbcode, "[quote]$1[/quote]", true)
	
	# 转换无序列表 (- item → [*]item)
	header_regex.compile("^\\-\\s+(.+)$")
	bbcode = header_regex.sub(bbcode, "[*]$1", true)
	
	# 转换有序列表 (1. item → [#]item)
	header_regex.compile("^\\d+\\.\\s+(.+)$")
	bbcode = header_regex.sub(bbcode, "[#]$1", true)
	
	return bbcode

# 获取转换后的发布说明（Markdown转BBCode）
func get_release_notes_as_bbcode() -> bool:
	if not get_latest_release_info():
		return false
	
	# 连接信号以处理异步获取
	if not release_info_loaded.is_connected(_on_release_info_loaded_for_bbcode):
		release_info_loaded.connect(_on_release_info_loaded_for_bbcode, CONNECT_ONE_SHOT)
	
	if not release_info_failed.is_connected(_on_release_info_failed_for_bbcode):
		release_info_failed.connect(_on_release_info_failed_for_bbcode, CONNECT_ONE_SHOT)
	
	return true

# 发布信息加载成功处理（用于BBCode转换）
func _on_release_info_loaded_for_bbcode(release_info: ReleaseInfo):
	# 转换Markdown到BBCode
	var bbcode_content = markdown_to_bbcode(release_info.body)
	print("AutoUpdater: 发布说明已转换为BBCode格式")
	
	# 这里可以发射一个新信号，或者直接使用现有信号
	# 为了灵活性，我们发射一个专用信号
	release_notes_bbcode_ready.emit(bbcode_content, release_info)

# 发布信息加载失败处理（用于BBCode转换）
func _on_release_info_failed_for_bbcode(error_message: String):
	push_error("AutoUpdater: 获取发布说明失败: " + error_message)
	release_notes_bbcode_failed.emit(error_message)

# 获取当前使用的镜像
func get_current_mirror() -> String:
	if _current_mirror_index < AVAILABLE_MIRRORS.size():
		return AVAILABLE_MIRRORS[_current_mirror_index]
	return ""

# 手动设置镜像（用于测试或用户选择）
func set_mirror(mirror: String):
	var index = AVAILABLE_MIRRORS.find(mirror)
	if index >= 0:
		_current_mirror_index = index
	else:
		push_warning("AutoUpdater: 镜像不在可用列表中")

# 静态方法：获取单例实例
static func get_instance() -> AutoUpdater:
	return instance

# 静态方法：检查更新（便捷方法）
static func check_for_update() -> bool:
	if instance != null:
		return instance.check_update()
	else:
		push_error("AutoUpdater 单例未初始化")
		return false

# 静态方法：执行更新（便捷方法）
static func perform_update():
	if instance != null:
		instance.update()
	else:
		push_error("AutoUpdater 单例未初始化")

# 静态方法：获取发布信息（便捷方法）
static func get_release_info() -> bool:
	if instance != null:
		return instance.get_latest_release_info()
	else:
		push_error("AutoUpdater 单例未初始化")
		return false

# 静态方法：获取BBCode格式的发布说明（便捷方法）
static func get_release_notes_in_bbcode() -> bool:
	if instance != null:
		return instance.get_release_notes_as_bbcode()
	else:
		push_error("AutoUpdater 单例未初始化")
		return false

# 新增信号：BBCode格式发布说明就绪
signal release_notes_bbcode_ready(bbcode_content: String, release_info: ReleaseInfo)
signal release_notes_bbcode_failed(error_message: String)

# 在节点退出时清理资源
func _exit_tree():
	if _current_http_request and is_instance_valid(_current_http_request):
		_current_http_request.queue_free()
		_current_http_request = null
