extends TextureRect

@export var dialogue_style: String = "light": ## 对话框样式
	set(value):
		# 判断值是否改变，未改变直接返回
		if value == dialogue_style:
			return
			
		# 重置内部状态
		current_texture_index = 0
		next_texture_timer = 0
		
		# 设置对话框样式
		dialogue_style = value
		
@export var text_animation_state: String = "playing": ## 对话文字动画状态
	set(value):
		# 判断值是否改变，未改变直接返回
		if value == text_animation_state:
			return
			
		# 重置内部状态
		current_texture_index = 0
		next_texture_timer = 0
		
		# 设置对话文字动画状态
		text_animation_state = value

var current_texture_index = 0 ## 当前纹理索引
var next_texture_timer = 0 ## 纹理切换计时器

func _process(delta: float) -> void:
	# 更新计时器
	next_texture_timer -= 1
	
	# 当计时器未到时时，返回
	if next_texture_timer > 0:
		return
		
	# 获取指定样式下的所有纹理
	var textures = AssetFinder.find_asset(AssetFinder.AssetType.DIALOGUE_TEXTURES, dialogue_style)
	
	# 根据文字动画状态筛选纹理
	var filtered_textures = textures.filter(
		func (texture_path: String):
			return (
				texture_path.get_file().replace(".%s" % texture_path.get_extension(), "").split("@")[1].split("-")[1] == text_animation_state or 
				texture_path.get_file().replace(".%s" % texture_path.get_extension(), "").split("@")[1].split("-")[1] == "all"
			)
	)
	
	# 获取当前纹理
	var current_texture = filtered_textures[current_texture_index]
	
	# 设置计时器
	next_texture_timer = int(current_texture.get_file().replace(".%s" % current_texture.get_extension(), "").split("@")[1].split("-")[0])
	
	# 加载纹理
	texture = AssetLoader.load_asset(current_texture)
	
	# 更新当前纹理索引
	if current_texture_index == len(filtered_textures) - 1:
		current_texture_index = 0
	else:
		current_texture_index += 1
