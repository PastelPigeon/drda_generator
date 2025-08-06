extends Node

## 将多个动画合并到一个动画当中（AI代码）
func merge_animations(animations: Array[Animation]) -> Animation:
	var merged_anim := Animation.new()
	var max_length: float = 0.0
	
	# 用于跟踪已添加的轨道路径（避免冲突）
	var track_paths := {}
	
	for anim in animations:
		if not anim:
			continue
		
		# 更新最大动画长度
		max_length = max(max_length, anim.length)
		
		# 复制所有轨道
		for track_idx in anim.get_track_count():
			var path: String = anim.track_get_path(track_idx)
			var type: int = anim.track_get_type(track_idx)
			var key_count: int = anim.track_get_key_count(track_idx)
			
			# 处理路径冲突：如果路径已存在，添加后缀
			var new_path = path
			
			# 添加轨道
			var new_track_idx = merged_anim.add_track(type)
			merged_anim.track_set_path(new_track_idx, new_path)
			merged_anim.track_set_interpolation_type(new_track_idx, anim.track_get_interpolation_type(track_idx))
			merged_anim.track_set_enabled(new_track_idx, anim.track_is_enabled(track_idx))
			
			# 当是value track时，保留update_mode属性
			if anim.track_get_type(track_idx) == Animation.TYPE_VALUE:
				merged_anim.value_track_set_update_mode(new_track_idx, anim.value_track_get_update_mode(track_idx))
			
			# 复制键值
			for key_idx in key_count:
				var time = anim.track_get_key_time(track_idx, key_idx)
				var value = anim.track_get_key_value(track_idx, key_idx)
				var transition = anim.track_get_key_transition(track_idx, key_idx)
				
				merged_anim.track_insert_key(
					new_track_idx,
					time,
					value,
					transition
				)
	
	# 设置合并后动画的总长度
	merged_anim.length = max_length
	return merged_anim
