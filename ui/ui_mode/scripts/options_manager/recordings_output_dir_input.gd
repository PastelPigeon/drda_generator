extends LineEdit

func _ready() -> void:
	text_changed.connect(_on_text_changed)

func _on_text_changed(_text: String):
	# 存储选项
	UmOptionsConfigManager.set_option(UmOptionsConfigManager.Option.RECORDINGS_OUTPUT_DIR, text)
