extends TextureRect

class_name Fadeable

enum Fade {
	WAIT,
	FADE_ON,
	ON,
	FADE_OFF,
	OFF
}

var fade_state : Fade = Fade.WAIT
var opacity = 0.0

func _process(delta):
	match fade_state:
		Fade.WAIT:
			opacity = 0.0
		Fade.FADE_ON:
			opacity = $FadeOnTime.wait_time - $FadeOnTime.time_left
		Fade.ON:
			opacity = 1.0
		Fade.FADE_OFF:
			opacity = $FadeOffTime.time_left
		Fade.OFF:
			opacity = 0.0
	
	self_modulate = Color(1.0, 1.0, 1.0, opacity)

func _start_fade_on():
	if fade_state == Fade.OFF: return
	
	fade_state = Fade.FADE_ON
	$FadeOnTime.start()

func _start_fade_off():
	if fade_state == Fade.OFF: return
	
	fade_state = Fade.FADE_OFF
	$FadeOffTime.start()

func _on_fade_on_time_timeout():
	fade_state = Fade.ON

func _on_fade_off_time_timeout():
	fade_state = Fade.OFF
