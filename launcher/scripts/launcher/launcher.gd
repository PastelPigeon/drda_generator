extends Control

func _ready() -> void:
	var cmdline_args_status = CmdlineParser.get_cmdline_args_status(OS.get_cmdline_args())["status"]
	
	if cmdline_args_status == CmdlineParser.CmdlineStatus.OK or cmdline_args_status == CmdlineParser.CmdlineStatus.EDITOR:
		var cmdline_args_dict = CmdlineParser.convert_cmdline_args_array_to_dict(OS.get_cmdline_args())
		
		var dialogue_scene_res: PackedScene = load("res://generator/generator.tscn")
		var dialogue_scene_ins = dialogue_scene_res.instantiate()
		
		add_child(dialogue_scene_ins)
		
		dialogue_scene_ins.dialogues = JSON.parse_string(FileAccess.open(cmdline_args_dict["dialogues"], FileAccess.READ).get_as_text())
		
		var options = cmdline_args_dict.duplicate()
		options.erase("dialogues")
		dialogue_scene_ins.options = cmdline_args_dict
	elif cmdline_args_status == CmdlineParser.CmdlineStatus.UI_MODE:
		var ui_mode_scene_res: PackedScene = load("res://ui/ui_mode/ui_mode.tscn")
		var ui_mode_scene_ins = ui_mode_scene_res.instantiate()
		add_child(ui_mode_scene_ins)
	else:
		var cmdline_args_dict = CmdlineParser.convert_cmdline_args_array_to_dict(OS.get_cmdline_args())
		var cmdline_status_dict = CmdlineParser.get_cmdline_args_status(OS.get_cmdline_args())
		
		var cmdline_alert_scene_res: PackedScene = load("res://ui/cmdline_alert/cmdline_alert.tscn")
		var cmdline_alert_scene_ins = cmdline_alert_scene_res.instantiate()
		
		add_child(cmdline_alert_scene_ins)
		
		cmdline_alert_scene_ins.cmdline_args_dict = cmdline_args_dict
		cmdline_alert_scene_ins.cmdline_status_dict = cmdline_status_dict
