extends VBoxContainer

## 更新预览
func update_preview(content: String):
	# 获取传入内容的报错信息
	var err_msg = EditorBbcodeParser.check_bbcode_string(content)
	var err_msg_user = EditorBbcodeParser.error_to_string(err_msg)
	
	# DEErrorMsgPanel
	if err_msg == EditorBbcodeParser.BbcodeStringError.NONE:
		%DEErrorMsgPanel.theme_type_variation = "de_error_msg_panel_ok"
	else:
		%DEErrorMsgPanel.theme_type_variation = "de_error_msg_panel_err"
		
	# ErrorMsg
	%ErrorMsg.text = err_msg_user
	
	# PreviewLabel
	%PreviewLabel.text = DialogueBbcodeTagsCleaner.clean_bbcode_tags_from_dialogue(content, DialogueBbcodeTagsCleaner.CONTROLLER_TAGS)
