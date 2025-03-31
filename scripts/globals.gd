extends Node

var Player_Position : Vector3 = Vector3.ZERO
var Just_Teleported : int = 0

var current_scene = null

func get_scene():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

var has_shown_tutorial : bool = false
var has_shown_jumping_tutorial : bool = false
var has_shown_schedule_tutorial : bool = false

func show_space():
	get_scene()
	var space_fadeable = current_scene.find_child("UI", true, false).find_child("Space_Fadeable", true, false) as Fadeable
	if space_fadeable and not has_shown_jumping_tutorial:
		has_shown_jumping_tutorial = true
		space_fadeable._start_fade_on()

func show_r():
	get_scene()
	var r_fadeable = current_scene.find_child("UI", true, false).find_child("R_Fadeable", true, false) as Fadeable
	if r_fadeable and not has_shown_schedule_tutorial:
		has_shown_schedule_tutorial = true
		r_fadeable._start_fade_on()

func show_image(image : String):
	get_scene()
	var image_tex : ImageDisplay = current_scene.find_child("UI", true, false).find_child("ImageDisplay", true, false)
	if not image_tex: return
	#print(image_tex)
	image_tex.get_child(0).texture = load(image)
	was_just_pressed = true # spaghetti :)
	image_tex.show_image()

func hide_image():
	get_scene()
	var UInode : CanvasLayer = current_scene.find_child("UI", true, false)
	if not UInode: return
	var image_tex : ImageDisplay = UInode.find_child("ImageDisplay", true, false)
	if image_tex:
		image_tex.hide_image()

var first_callstone : int = 0
var second_callstone : int = 0
var third_callstone : int = 0

var things_seen : Array[bool] = [false, false, false, false, false]
func callstone():
	get_scene()
	var player : CharacterBody3D = current_scene.find_child("Character", true, false)
	
	var closest_callstone_to_player : Callstone
	for child in current_scene.get_children():
		if child is Callstone:
			if not closest_callstone_to_player:
				closest_callstone_to_player = child
			else:
				if child.global_position.distance_to(player.global_position) < closest_callstone_to_player.global_position.distance_to(player.global_position):
						closest_callstone_to_player = child
	
	closest_callstone_to_player.animate()
	# get closest callstone

func all_things_seen() -> bool:
	for thing in things_seen:
		if thing == false:
			return false
	return true

func check_win() -> bool:
	# get UI
	get_scene()
	var UInode : Game_UI = current_scene.find_child("UI", true, false)
	return UInode.check_win()
	
var winfadetimer : SceneTreeTimer
var win_ui
func win():
	get_scene()
	win_ui = load("res://scenes/endscreen.tscn")
	for child in win_ui.get_children():
		child.self_modulate.a = 0.0
	current_scene.add_child(win_ui)
	
	winfadetimer = get_tree().create_timer(1)
	winfadetimer.timeout.connect(win_scene) # hacky but what isn't

func win_scene():
	goto_scene("res://scenes/endscreen.tscn")
	
var was_just_pressed = false
func _process(delta):
	if Input.is_anything_pressed() and not was_just_pressed:
		was_just_pressed = true
		hide_image()
	
	if not Input.is_anything_pressed():
		was_just_pressed = false
		
	if winfadetimer:
		for child in win_ui.get_children():
			child.self_modulate.a = 1 - winfadetimer.time_left

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
