extends Control

signal properties_changed

@export var cmdline_args_dict: Dictionary: ## 命令行参数字典
	set(value):
		cmdline_args_dict = value
		properties_changed.emit()
		
@export var cmdline_status_dict: Dictionary: ## 命令行参数状态字典
	set(value):
		cmdline_status_dict = value
		properties_changed.emit()
		
func _ready() -> void:
	properties_changed.connect(_on_properties_changed)
		
func _on_properties_changed():
	if cmdline_args_dict and cmdline_status_dict:
		$"Window/VSplitContainer/MarginContainer/WindowContent/MarginContainer/VBoxContainer/AlertHeader/CenterContainer/HBoxContainer/VBoxContainer/ErrorMessage".text = cmdline_status_dict["user"]
