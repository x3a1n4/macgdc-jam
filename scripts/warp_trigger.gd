extends Area3D

@export_category("Warp")
@export_file("*.tscn") var scene : String
@export var warp_pos : Vector3

func _on_body_entered(body) -> void:
	print("entered")
	if body is CharacterBody3D:
		if not Globals.Just_Teleported:
			# set global var
			Globals.Player_Position = warp_pos
			Globals.Just_Teleported = 2
			
			Globals.goto_scene(scene)
			#tree.change_scene_to_file(scene)


func _on_body_exited(body):
	# unload old scene
	print("left")
	if body is CharacterBody3D:
		# wait two seconds
		Globals.Just_Teleported -= 1
		return
