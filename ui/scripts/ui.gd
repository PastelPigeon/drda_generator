extends Control

func _ready() -> void:
	# 绑定信号
	SystemThemeDetector.system_theme_changed.connect(_on_system_theme_changed)
	
	# 手动更新主题
	theme = DynamicThemeGenerator.generate_dynamic_theme(DynamicThemeGenerator.ThemeScheme.LIGHT if SystemThemeDetector.get_system_theme_scheme() == SystemThemeDetector.SystemThemeScheme.LIGHT else DynamicThemeGenerator.ThemeScheme.DARK, SystemThemeDetector.get_system_theme_accent_color())

## 当系统主题改变时执行
func _on_system_theme_changed(new_scheme: SystemThemeDetector.SystemThemeScheme, new_accent_color: Color):
	# 更新主题
	theme = DynamicThemeGenerator.generate_dynamic_theme(DynamicThemeGenerator.ThemeScheme.LIGHT if new_scheme == SystemThemeDetector.SystemThemeScheme.LIGHT else DynamicThemeGenerator.ThemeScheme.DARK, new_accent_color)
