extends Area3D

@export var die_position : Vector3 

func _on_body_entered(body):
	if body is PlayerCharacter:
		body._die(die_position)
