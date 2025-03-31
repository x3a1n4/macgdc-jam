extends Node3D

class_name Callstone

@export var variable_name : String = "[Global].[name]"

func _ready():
	pass

func _enter_tree():
	# get global
	# this is very bad
	var script : GDScript = GDScript.new()
	script.source_code += "extends Node\n"
	script.source_code += "static func _eval():\n\treturn " + variable_name
	script.reload()
	var num = script._eval()
	
	print(num)
	if num == 0:
		# haven't interacted
		$call_collection/Armature/Skeleton3D.visible = false
	else:
		# have interacted
		$call_collection/AnimationPlayer.play("Rest")

func animate():
	$call_collection/Armature/Skeleton3D.visible = true
	$GPUParticles3D.emitting = true
	$call_collection/AnimationPlayer.play("Pop Up")
