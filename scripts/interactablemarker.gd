extends MeshInstance3D

@export_category("Area")
@export var fade : Curve
@export var range = 5.0
@export var close_range = 1.0

@export_category("Dialogue")
@export var dialogue_resource : DialogueResource
@export var starting_point : String = "start"

@export_category("Other")
@export var offset : Vector2i

var character : CharacterBody3D
var camera : Camera3D
	
func _ready():
	# get player
	for child in get_parent().get_children():
		print(child)
		if child is CharacterBody3D:
			character = child
		if child is Camera3D:
			camera = child

var can_interact : bool = true

func _process(delta):
	
	# get distance
	var distance = (position - character.position).length()
	var opacity = 0.0
	
	if distance < range:
		opacity = fade.sample(distance / range) * 0.8
	
	if distance < close_range and can_interact:
		opacity = 1.0
		if Input.is_action_pressed("interact"):
			can_interact = false
			DialogueManager.show_example_dialogue_balloon(dialogue_resource, starting_point)
	else:
		can_interact = true
	
	$CanvasLayer/TextureRect.self_modulate = Color(1, 1, 1, opacity)
	$CanvasLayer/TextureRect.position = camera.unproject_position(global_position) + Vector2(offset)
