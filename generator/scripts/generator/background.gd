extends ColorRect

func _ready() -> void:
	owner.properties_changed.connect(_on_properties_changed)
	
func _on_properties_changed():
	if owner.options.has("background"):
		color = Color(owner.options["background"])
