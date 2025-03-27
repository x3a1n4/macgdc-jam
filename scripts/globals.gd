extends Node

var Player_Position : Vector3 = Vector3.ZERO
var Just_Teleported : int = 0

var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

var has_shown_tutorial : bool = false
var has_shown_jumping_tutorial : bool = false

func show_space():
	var space_fadeable = current_scene.find_child("UI", true, false).find_child("Space_Fadeable", true, false) as Fadeable
	if space_fadeable and not has_shown_jumping_tutorial:
		has_shown_jumping_tutorial = true
		space_fadeable._start_fade_on()

func show_image(image : String):
	var image_tex : ImageDisplay = current_scene.find_child("UI", true, false).find_child("ImageDisplay", true, false)
	print(image_tex)
	image_tex.get_child(0).texture = load(image)
	was_just_pressed = true # spaghetti :)
	image_tex.show_image()

func hide_image():
	var image_tex : ImageDisplay = current_scene.find_child("UI", true, false).find_child("ImageDisplay", true, false)
	image_tex.hide_image()

var was_just_pressed = false
func _process(delta):
	if Input.is_anything_pressed() and not was_just_pressed:
		was_just_pressed = true
		hide_image()
	
	if not Input.is_anything_pressed():
		was_just_pressed = false

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s : PackedScene = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
