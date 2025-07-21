extends Control

signal properties_changed

@export var dialogues: Array: 
	set(value):
		dialogues = value
		properties_changed.emit()
		
@export var options: Dictionary:
	set(value):
		options = value
		properties_changed.emit()
