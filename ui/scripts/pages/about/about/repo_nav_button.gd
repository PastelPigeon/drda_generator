extends Button

## 跳转链接
const URL = "https://github.com/PastelPigeon/drda_generator"

func _pressed() -> void:
	# 跳转到指定链接
	OS.shell_open(URL)
