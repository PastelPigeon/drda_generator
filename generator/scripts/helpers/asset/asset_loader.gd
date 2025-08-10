extends Node

## 加载指定资源（加载失败时返回null）
func load_asset(path: String):
	# 判断指定资源是否存在，不存在返回null
	if FileAccess.file_exists(path) == false:
		return null
		
	# 判断是否为内置资源（且不为json资源），内置资源通过load加载
	if path.begins_with("res://") and path.ends_with(".json") == false:
		return load(path)
		
	# 获取指定资源扩展名
	var asset_ext = path.get_extension()
	
	# 根据不同扩展选择不同加载方式
	match asset_ext:
		"png":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载图片
			var image = Image.new()
			image.load_png_from_buffer(buffer)
			
			# 将图片加载到纹理
			var texture = ImageTexture.create_from_image(image)
			
			return texture
		"bmp":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载图片
			var image = Image.new()
			image.load_bmp_from_buffer(buffer)
			
			# 将图片加载到纹理
			var texture = ImageTexture.create_from_image(image)
			
			return texture
		"jpg":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载图片
			var image = Image.new()
			image.load_jpg_from_buffer(buffer)
			
			# 将图片加载到纹理
			var texture = ImageTexture.create_from_image(image)
			
			return texture
		"ktx":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载图片
			var image = Image.new()
			image.load_ktx_from_buffer(buffer)
			
			# 将图片加载到纹理
			var texture = ImageTexture.create_from_image(image)
			
			return texture
		"svg":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载图片
			var image = Image.new()
			image.load_svg_from_buffer(buffer)
			
			# 将图片加载到纹理
			var texture = ImageTexture.create_from_image(image)
			
			return texture
		"tga":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载图片
			var image = Image.new()
			image.load_tga_from_buffer(buffer)
			
			# 将图片加载到纹理
			var texture = ImageTexture.create_from_image(image)
			
			return texture
		"webp":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载图片
			var image = Image.new()
			image.load_webp_from_buffer(buffer)
			
			# 将图片加载到纹理
			var texture = ImageTexture.create_from_image(image)
			
			return texture
		"wav":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载音频
			var audio_stream = AudioStreamWAV.load_from_buffer(buffer)
			
			return audio_stream
		"mp3":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载音频
			var audio_stream = AudioStreamMP3.load_from_buffer(buffer)
			
			return audio_stream
		"ogg":
			# 获取资源文件buffer
			var file = FileAccess.open(path, FileAccess.READ)
			var buffer = file.get_buffer(file.get_length())
			file.close()
			
			# 加载音频
			var audio_stream = AudioStreamOggVorbis.load_from_buffer(buffer)
			
			return audio_stream
		"json":
			# 获取文件内容
			var file = FileAccess.open(path, FileAccess.READ)
			var content = JSON.parse_string(file.get_as_text())
			file.close()
			
			return content
		_:
			# 不支持的扩展名返回null
			return null
