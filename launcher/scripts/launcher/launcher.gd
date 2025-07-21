extends Control

func _ready() -> void:
	var cmdline_args_status = CmdlineParser.get_cmdline_args_status(OS.get_cmdline_args())["status"]
	
	if cmdline_args_status == CmdlineParser.CmdlineStatus.OK or cmdline_args_status == CmdlineParser.CmdlineStatus.EDITOR:
		var cmdline_args_dict = CmdlineParser.convert_cmdline_args_array_to_dict(OS.get_cmdline_args())
		
		var dialogue_scene_res: PackedScene = load("res://generator/generator.tscn")
		var dialogue_scene_ins = dialogue_scene_res.instantiate()
		
		add_child(dialogue_scene_ins)
		
		dialogue_scene_ins.dialogues = JSON.parse_string(FileAccess.open(cmdline_args_dict["dialogues"], FileAccess.READ).get_as_text())
		dialogue_scene_ins.options = {
			"fps": cmdline_args_dict["fps"],
			"background": cmdline_args_dict["background"],
			"recording_mode": cmdline_args_dict["recording_mode"],
			"recordings_output_dir": cmdline_args_dict["recordings_output_dir"]
		}
	elif cmdline_args_status != CmdlineParser.CmdlineStatus.UI_MODE:
		var cmdline_args_dict = CmdlineParser.convert_cmdline_args_array_to_dict(OS.get_cmdline_args())
		var cmdline_status_dict = CmdlineParser.get_cmdline_args_status(OS.get_cmdline_args())
		
		var alert_screen_scene_res: PackedScene = load("res://ui/alert_screen/alert_screen.tscn")
		var alert_screen_scene_ins = alert_screen_scene_res.instantiate()
		
		add_child(alert_screen_scene_ins)
		
		alert_screen_scene_ins.cmdline_args_dict = cmdline_args_dict
		alert_screen_scene_ins.cmdline_status_dict = cmdline_status_dict
