extends Panel

class_name CalendarElement

const default_color = Color.BLACK

@export var type : String = "Default" :
	set(value):
		if value in CalendarType.names():
			type = value

var StartTime : float = 8.5
var EndTime : float = 15.5
var OnCalendar : bool = true

#const TypeFormat = "[b]%s[/b]"
const TimeFormat = "[p align=center][b]%d:%02d[/b] %s  -  [b]%d:%02d[/b] %s"

var gameUI : Game_UI

var is_hovering : bool = false

const default_border_size : int = 3

var cursorSound : AudioStream = load(
	"res://assets/audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.mp3"
)
var menuOpenSound : AudioStream = load(
	"res://assets/audio/ui/JDSherbert - Ultimate UI SFX Pack - Cursor - 4.mp3"
)
var menuSelectedSound : AudioStream = load(
	"res://assets/audio/ui/JDSherbert - Ultimate UI SFX Pack - Select - 1.mp3"
)

func _ready():
	var popup : PopupMenu = $BigBox/TypeLabel.get_popup()
	popup.id_pressed.connect(_on_type_selected)

	for i in range(1, len(CalendarType.names())):
		var name = CalendarType.names()[i]
		var index = i-1
		
		popup.add_item(name, index)
		popup.set_item_text(index, name)

func _enter_tree():
	gameUI = get_tree().root.find_child("UI", true, false) # this works most of the time
	
	for child in get_tree().root.get_children(true):
		if child.name == "UI": # ehhhhh
			gameUI = child
			break
	
	if not gameUI:
		push_error("Couldn't find gameUI")

enum MoveAction{
	DRAG_TOP,
	DRAG_BOTTOM,
	DRAG_WHOLE,
	NONE
}
var move_action_state : MoveAction = MoveAction.NONE

var old_mouse : Vector2 = Vector2.ZERO
func _process(delta):
	var start_hour = fmod(floor(StartTime), 12)
	var start_type_am : bool = false
	if StartTime < 13:
		start_type_am = true
	
	if start_hour == 0: 
		start_hour = 12
		start_type_am = !start_type_am
	
	var start_minute = fmod(fmod(StartTime, 1), 12) * 60
	
	var end_hour = fmod(floor(EndTime), 12)
	
	var end_type_am : bool = false
	if EndTime < 13:
		end_type_am = true
	
	if end_hour == 0: 
		end_hour = 12
		end_type_am = !end_type_am
	
	var end_minute = fmod(fmod(EndTime, 1), 12) * 60
	
	var start_type_text = "AM" if start_type_am else "PM"
	var end_type_text = "AM" if end_type_am else "PM"
	
	get_theme_stylebox("panel").set("bg_color", CalendarType.from_name(type).colour)
	$BigBox/TypeLabel.text = type
	$BigBox/TimeLabel.text = TimeFormat % [
		start_hour, start_minute, start_type_text, 
		end_hour, end_minute, end_type_text]
	
	$SmallLabel.text = $BigBox/TimeLabel.text
	
#region Resizing
	
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var mouse_delta = mouse_pos - old_mouse
	
	if Input.is_action_pressed("mouse_interact"):
		if move_action_state == MoveAction.NONE:
			if is_hovering:
				if $UpperDragBox.get_global_rect().has_point(mouse_pos):
					move_action_state = MoveAction.DRAG_TOP
					#Input.action_release("mouse_interact")
				elif $LowerDragBox.get_global_rect().has_point(mouse_pos):
					move_action_state = MoveAction.DRAG_BOTTOM
					#Input.action_release("mouse_interact")
				elif get_global_rect().has_point(mouse_pos):
					move_action_state = MoveAction.DRAG_WHOLE
					#Input.action_release("mouse_interact")
	else:
		move_action_state = MoveAction.NONE
	
	if $UpperDragBox.get_global_rect().has_point(mouse_pos):
		get_theme_stylebox("panel").set("border_width_top", 6)
	else:
		get_theme_stylebox("panel").set("border_width_top", default_border_size)
		
	if $LowerDragBox.get_global_rect().has_point(mouse_pos):
		get_theme_stylebox("panel").set("border_width_bottom", 6)
	else:
		get_theme_stylebox("panel").set("border_width_bottom", default_border_size)
	
	# if dummy, return
	if name == "DummyEvent":
		return
	
	match move_action_state:
		MoveAction.DRAG_TOP:
			var oldy = position.y
			position.y += mouse_delta.y
			size.y += oldy - position.y
		MoveAction.DRAG_BOTTOM:
			var oldy = size.y
			size.y += mouse_delta.y
		MoveAction.DRAG_WHOLE:
			position.y += mouse_delta.y
		MoveAction.NONE:
			global_position.y = gameUI.snap_to_time(global_position.y)
			StartTime = gameUI.snap_to_hour(global_position.y)
			
			size.y = gameUI.snap_to_time(size.y + global_position.y) - global_position.y
			EndTime = gameUI.snap_to_hour(size.y + global_position.y)
			
			if size.y == 0: 
				size.y = 15
				EndTime += 0.5
	
	# visual edit
	if size.y < 30:
		# hide elements
		$BigBox/TypeLabel.visible = false
		$BigBox/TimeLabel.visible = false
		$SmallLabel.visible = true
		
	elif size.y < 70:
		$BigBox/TypeLabel.visible = false
		$BigBox/TimeLabel.visible = true
		$SmallLabel.visible = false
	else:
		$BigBox/TypeLabel.visible = true
		$BigBox/TimeLabel.visible = true
		$SmallLabel.visible = false
		

#endregion
	# deletion
	if Input.is_action_pressed("mouse_delete") and get_global_rect().has_point(mouse_pos):
		Input.action_release("mouse_delete")
		# delete
		queue_free()
		
	#get_theme_stylebox("panel").duplicate()
	old_mouse = mouse_pos


func duplicate_element(flags: int = 15) -> CalendarElement:
	var new_event : CalendarElement = duplicate(flags)
	new_event.set("theme_override_styles/panel", new_event.get_theme_stylebox("panel").duplicate(true))
	new_event.get_node("BigBox/TypeLabel").get_popup().clear()
	
	return new_event

func _on_type_selected(id):
	var index = id + 1
	type = CalendarType.names()[index]
	
	$UI_Sound.stream = menuSelectedSound
	$UI_Sound.play()

func _on_mouse_entered():
	get_theme_stylebox("panel").set("bg_color", CalendarType.from_name(type).colour * 1.1)
	is_hovering = true
	
	$UI_Sound.stream = cursorSound
	$UI_Sound.play()

func _on_mouse_exited():
	get_theme_stylebox("panel").set("bg_color", CalendarType.from_name(type).colour)
	is_hovering = false

# play sound
func _on_type_label_about_to_popup():
	$UI_Sound.stream = menuOpenSound
	$UI_Sound.play()
