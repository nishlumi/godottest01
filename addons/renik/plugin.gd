@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	# Add the new type with a name, a parent type, a script and an icon.
	add_custom_type("RenIK3D", "Node3D", preload("renik.gd"), null)
	add_custom_type("RenIKPlacement3D", "Node3D", preload("renik_placement.gd"), null)

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("RenIK3D")
