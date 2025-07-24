extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_item_selected)

func _on_item_selected(_selected: int):
	# 存储设置
	UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.RECORDING_MODE, "single" if selected == 0 else "multiple")
