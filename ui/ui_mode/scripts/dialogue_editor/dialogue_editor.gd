extends Control

signal content_edit_text_changed(content: String) ## 当内容编辑器的文字改变时

## 警告页面的图标的资源路径
const AlertIconAssetPaths = [
	"res://ui/assets/icons/ui_mode/no_selected_dialogue_icon_1.png",
	"res://ui/assets/icons/ui_mode/no_selected_dialogue_icon_2.png",
	"res://ui/assets/icons/ui_mode/no_selected_dialogue_icon_3.png"
]

@export var dialogues: Control: ## Dialogues节点
	set(value):
		# 设置dialogues
		dialogues = value
		
		# 判断是否为空值
		if dialogues != null:
			# 连接信号
			dialogues.dialogues_changed.connect(_on_dialogues_changed)
			dialogues.selected_dialogue_id_changed.connect(_on_selected_dialogue_id_changed)
			
			# 手动执行一次信号接受时所执行的函数
			_on_dialogues_changed()
			_on_selected_dialogue_id_changed()
			
## 当dialogues改变时
func _on_dialogues_changed():
	pass
	
## 当selected_dialogue_id改变时
func _on_selected_dialogue_id_changed():
	# 判断有无选中对话
	if dialogues.selected_dialogue_id == -1:
		# 没有选中对话时，显示警告页面
		%AlertIcon.texture = load(AlertIconAssetPaths[randi_range(0, 2)])
		
		%Normal.visible = false
		%NoSelectedDialogueAlert.visible = true
	else:
		# 选中对话时，设置ContentEdit内容并更新Preview
		%ContentEdit.text = dialogues.dialogues[dialogues.dialogues.find(dialogues.dialogues.filter(func (dialogue): return dialogue["dialogue_id"] == dialogues.selected_dialogue_id)[0])]["content"]
		%Preview.update_preview(%ContentEdit.text)
		
		%Normal.visible = true
		%NoSelectedDialogueAlert.visible = false
		
