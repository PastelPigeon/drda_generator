extends ColorPickerButton

func _ready() -> void:
	color_changed.connect(_on_color_changed)

func _on_color_changed(_color: Color):
	# 存储设置
	UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.BACKGROUND, color.to_html())
