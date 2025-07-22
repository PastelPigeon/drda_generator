extends Control

signal remove_button_pressed(dialogue_id: int) ## 当删除按钮按下

@export var dialogue_id: int ## 随机生成的对话id（用于区分不同的对话节点）

var content = "" ## 当前对话内容
