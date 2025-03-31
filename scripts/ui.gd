extends CanvasLayer

class_name Game_UI

@onready var schedule_view_pos = $"Schedule Container".position
@onready var schedule_off_pos = schedule_view_pos + Vector2.RIGHT * $"Schedule Container".size
var is_schedule_open : bool = false
@onready var target_schedule_position : Vector2 = schedule_off_pos

@onready var win_dialogue : DialogueResource = load("res://dialogue/win.dialogue")

var hour_heights : Array[float]

var openSound : AudioStream = load(
	"res://assets/audio/ui/JDSherbert - Ultimate UI SFX Pack - Popup Open - 1.mp3"
)
var closeSound : AudioStream = load(
	"res://assets/audio/ui/JDSherbert - Ultimate UI SFX Pack - Popup Close - 1.mp3"
)

func _ready():
	# show tutorial
	if not Globals.has_shown_tutorial:
		$WASD_Fadeable._start_fade_on()
		Globals.has_shown_tutorial = true
	
	$"Schedule Container".position = schedule_off_pos

var has_won : bool = false
const win_con : Array[Array] = [
	[0.0, 7.0, "Sleeping"],
	[7.0, 13.0, "Working"],
	[13.0, 14.0, "Eating"],
	[14.0, 22.5, "Working"],
]

func _enter_tree():
	# set music
	#print(get_parent().name)
	if get_parent().name == "Interior":
		$Music.stream = load("res://assets/audio/Sketchbook 2024-12-04.ogg")
	elif get_parent().name == "Game":
		$Music.stream = load("res://assets/audio/Polar Lights.wav")
	
	# instantiate tickmarkers
	for i in range(1, 47):
		var new_node : HSeparator = $"Schedule Container/BG/TickMarker".duplicate()
		new_node.position = $"Schedule Container/BG/TickMarker".position + Vector2.DOWN * $"Schedule Container/BG".size.y * i/47
		$"Schedule Container/BG".add_child(new_node)
		$"Schedule Container/BG".move_child(new_node, 0)
		
		if i % 2 == 1:
			new_node.self_modulate.a = 0.3
		
		hour_heights.append(new_node.global_position.y)
	
	# get calendar elements
	print(Globals.calendar_children)
	for child in Globals.calendar_children:
		var new_event : CalendarElement = $"Schedule Container/BG/DummyEvent".duplicate_element()
		
		new_event.position.y = child[0]
		new_event.size.y = child[1]
		# magic numbers babeyyy
		new_event.position.x = 13
		new_event.type = child[2]
		new_event.visible = true
		
		$"Schedule Container/BG".add_child(new_event)
		
		print(new_event.size.x)
	
	Globals.calendar_children = []

func _process(delta):
	var opacity = 0.0
	
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_forward"):
		$WASD_Fadeable._start_fade_off()
		
	if Input.is_action_just_pressed("jump"):
		$Space_Fadeable._start_fade_off()
	
	if Input.is_action_just_pressed("open_schedule"):
		$R_Fadeable._start_fade_off()
	
	if Input.is_action_just_pressed("open_schedule"):
		Input.action_release("open_schedule")
		
		if is_schedule_open:
			# turn off
			is_schedule_open = false
			target_schedule_position = schedule_off_pos
			
			$UI_Sound.stream = closeSound
			$UI_Sound.play()
		else:
			# turn on
			is_schedule_open = true
			target_schedule_position = schedule_view_pos
			
			$UI_Sound.stream = openSound
			$UI_Sound.play()
	$"Schedule Container".position = lerp($"Schedule Container".position, target_schedule_position, 0.1)
	
	# hack

func check_win() -> bool:
	# check calendar
	var calendar : Array[Array] = []
	for child in $"Schedule Container/BG".get_children():
		if child is CalendarElement:
			calendar.append([child.StartTime, child.EndTime, child.type])
	
	var winning : bool = true
	for correct_element in win_con:
		if correct_element not in calendar:
			winning = false
			break
	if winning and not has_won:
		return true
	return false

func snap_to_time(height : float) -> float:
	var minimal_height = hour_heights[0]
	for h in hour_heights:
		if abs(height-h) < abs(height-minimal_height):
			minimal_height = h
	
	return minimal_height
	
func snap_to_hour(height : float) -> float:
	return hour_heights.find(snap_to_time(height)) * 0.5

func _on_button_pressed():
	# add event
	var new_event : CalendarElement = $"Schedule Container/BG/DummyEvent".duplicate_element()
	$"Schedule Container/BG".add_child(new_event)
	
	new_event.position += Vector2.DOWN * 300
	new_event.visible = true

func _on_music_finished():
	# loop
	$Music.play()
