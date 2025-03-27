extends Panel

class_name ImageDisplay

@onready var show_position : Vector2 = position
@onready var show_rotation : float = rotation

@onready var hide_position : Vector2 = position + Vector2.DOWN * DisplayServer.screen_get_size().y
@onready var hide_rotation : float = 3

@onready var target_position : Vector2 = hide_position
@onready var target_rotation : float = hide_rotation

func _ready():
	position = hide_position
	rotation = hide_rotation

func _process(delta):
	position = lerp(position, target_position, 0.05)
	rotation = lerp(rotation, target_rotation, 0.05)

func show_image():
	target_position = show_position
	target_rotation = show_rotation

func hide_image():
	target_position = hide_position
	target_rotation = hide_rotation
