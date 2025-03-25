extends CanvasLayer

enum WASDFade {
	WAIT,
	FADE_ON,
	ON,
	FADE_OFF
}

var wasd_state : WASDFade = WASDFade.WAIT
	
func _ready():
	# show tutorial
	if not Globals.has_shown_tutorial:
		$Wasd/WaitToFadeTime.start()
		Globals.has_shown_tutorial = true

func _process(delta):
	var opacity = 0.0
	match wasd_state:
		WASDFade.WAIT:
			opacity = 0.0
		WASDFade.FADE_ON:
			opacity = $Wasd/FadeOnTime.wait_time - $Wasd/FadeOnTime.time_left
		WASDFade.ON:
			opacity = 1.0
		WASDFade.FADE_OFF:
			opacity = $Wasd/FadeOffTime.time_left
	
	# hell
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_forward"):
		$Wasd/FadeOnTime.start()
		wasd_state = WASDFade.FADE_OFF
	
	$Wasd.self_modulate = Color(1.0, 1.0, 1.0, opacity)
