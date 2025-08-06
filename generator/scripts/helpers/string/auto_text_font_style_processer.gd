extends Node

## 设置文本字体样式
func set_text_font_style(text: String, font_size: int, zh_font_path: String, en_font_path: String) -> String:
	# 定义中文Unicode范围 (包括汉字和全角字符)
	const CJK_RANGES = [
		[0x4E00, 0x9FFF],   # 基本汉字
		[0x3400, 0x4DBF],   # 扩展A区
		[0x20000, 0x2A6DF], # 扩展B区
		[0x3000, 0x303F],   # CJK标点符号（全角）
		[0xFF00, 0xFFEF]    # 全角/半角形式块
	]
	
	# 结果字符串构建器
	var output := PackedStringArray()
	var current_block := ""
	var current_font := ""
	
	# 包裹整个文本的字体大小标签
	output.append("[font_size=%d]" % font_size)
	
	# 处理每个字符
	for i in range(text.length()):
		var char = text[i]
		var char_code = char.unicode_at(0)
		var is_cjk := false
		
		# 检查字符是否在中文范围内
		for range in CJK_RANGES:
			if char_code >= range[0] and char_code <= range[1]:
				is_cjk = true
				break
		
		# 确定当前字符应使用的字体
		var required_font = zh_font_path if is_cjk else en_font_path
		
		# 当字体切换时结束当前块
		if required_font != current_font and not current_block.is_empty():
			output.append("[font=%s]%s[/font]" % [current_font, current_block])
			current_block = ""
		
		# 开始新块（如果当前块为空）
		if current_block.is_empty():
			current_font = required_font
		
		current_block += char
	
	# 添加最后一个文本块
	if not current_block.is_empty():
		output.append("[font=%s]%s[/font]" % [current_font, current_block])
	
	# 结束字体大小标签
	output.append("[/font_size]")
	
	return "".join(output)
