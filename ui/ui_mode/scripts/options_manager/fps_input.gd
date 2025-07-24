extends SpinBox

func _ready() -> void:
	value_changed.connect(_on_value_changed)

func _on_value_changed(_value: float):
	# 更新值
	UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.FPS, value)
