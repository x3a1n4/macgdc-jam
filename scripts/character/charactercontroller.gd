extends CharacterBody3D
# Default script from godot!

@export_group("Movement")
# How fast the player moves in meters per second.
@export var ground_speed = 14
# How fast the player moves while gliding in meters per second.
@export var glide_speed = 14
@export var glide_speed_acceleration = 0.2
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# The gliding fall speed of the character
@export var glide_downwards_velocity = 3
# The turn speed of the character
@export var turn_speed = 0.5
# The glide turn speed of the character
@export var glide_turn_speed = 0.05

# The jump curve
@export var jump_curve : Curve

@export_group("Animation")
# The lerp for walking/running
@export var walk_run_lerp = 0.5

@export_group("Other")
@export var camera : Camera3D

@onready var anim_tree := $AnimationTree as AnimationTree
@onready var state_machine := anim_tree.get("parameters/playback") as AnimationNode

@onready var camera_offset = camera.position - position 

enum State{
	GROUNDED,
	JUMPING,
	GLIDING,
	FALLING
}
var current_state : State = State.FALLING
	
# todo:
# turn smoothly
# jump

var target_velocity = Vector3.ZERO
var can_move = true

func _ready():
	SimpleGrass.set_interactive(true)
	
	DialogueManager.dialogue_started.connect(_on_dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _physics_process(delta):
#region Init
	# reset animation conditions
	$AnimationTree.set("parameters/conditions/jump", false)
	$AnimationTree.set("parameters/conditions/landing", false)
	
#endregion

	# We create a local variable to store the input direction.
#region Lateral Movement
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.

	# turn
	if direction != Vector3.ZERO:
		match current_state:
			State.GLIDING, State.JUMPING, State.FALLING:
				$characterv2.basis = lerp($characterv2.basis, Basis.looking_at(direction), glide_turn_speed)
			State.GROUNDED:
				$characterv2.basis = lerp($characterv2.basis, Basis.looking_at(direction), turn_speed)
	
	# set speed
	var speed = 0.0
	match current_state:
		State.GROUNDED, State.JUMPING:
			speed = ground_speed
		State.GLIDING:
			speed = lerp(velocity.length(), float(glide_speed), glide_speed_acceleration)
		State.FALLING:
			speed = ground_speed * 0.5 # hardcoded for now
	
	if not can_move:
		direction = Vector3.ZERO
	
	if direction == Vector3.ZERO:
		speed = 0
	
	# note that we only want to walk forwards
	# so with the speed, just go forwards
	
	target_velocity = Vector3(0, 0, -speed).rotated(Vector3.UP, $characterv2.rotation.y)
	if current_state == State.GROUNDED:
		target_velocity = direction.normalized() * speed # if grounded, change direction immediately instead
		
	# set blend space
	$AnimationTree.set("parameters/Run/blend_position", lerp(
		$AnimationTree.get("parameters/Run/blend_position"),
		direction.length(),
		walk_run_lerp
	))
	
	# TODO: ik the legs? seems easier to do programatically
#endregion

#region Jump and Glide
	# buffer for jumping
	if Input.is_action_pressed("jump"):
		$"Jump Buffer".start()
		
		Input.action_release("jump") # release jump
	
	# buffer for coyote time
	if is_on_floor() and $"Jump Timer".time_left == 0:
		$"Coyote Time".start()
		
		# landing
		$AnimationTree.set("parameters/conditions/landing", true)
		
		# set state
		current_state = State.GROUNDED
	
	# jumping!
	if $"Coyote Time".time_left > 0 and $"Jump Buffer".time_left > 0:
		# start animation
		$AnimationTree.set("parameters/conditions/jump", true)
		
		# start jump
		$"Jump Path/PathFollow3D".progress_ratio = 0
		$"Jump Timer".start()
		
		# end Jump Buffer
		$"Jump Buffer".stop()
		
		# set state
		current_state = State.JUMPING
	
	# stop gliding!
	if current_state == State.GLIDING:
		# start falling when floorcast collides
		if $Floorcast.is_colliding() or ($"Coyote Time".time_left == 0 and $"Jump Buffer".time_left > 0):
			$AnimationTree.set("parameters/conditions/landing", true)
			
			# set state
			current_state = State.FALLING
	
	# jump movement
	match current_state:
		State.GROUNDED:
			pass
		State.JUMPING:
			# get progress
			var progress = ($"Jump Timer".wait_time - $"Jump Timer".time_left) / $"Jump Timer".wait_time
			progress = jump_curve.sample(progress)
			
			# set to arc position
			var oldPos = $"Jump Path/PathFollow3D".position
			$"Jump Path/PathFollow3D".progress_ratio = progress
			var deltaPos = $"Jump Path/PathFollow3D".position - oldPos
			
			target_velocity = deltaPos / delta;
			
		State.GLIDING:
			target_velocity.y = -glide_downwards_velocity
			
		State.FALLING:
			target_velocity.y = velocity.y - (fall_acceleration * delta)
#endregion
	# print(can_move)
	# Moving the Character
	velocity = target_velocity
	
	if not can_move:
		velocity = Vector3.ZERO
	
	move_and_slide()
		
	SimpleGrass.set_player_position(global_position)

func _on_coyote_time_timeout() -> void:
	# we fell off a platform!
	if $"Jump Timer".is_stopped():
		$AnimationTree.set("parameters/conditions/jump", true)
		current_state = State.GLIDING

func _process(delta: float) -> void:
	# manage camera
	camera.position = position + camera_offset

func _on_jump_timer_timeout() -> void:
	# we're gliding!
	current_state = State.GLIDING

func _on_dialogue_start(resource: DialogueResource):
	can_move = false
	
func _on_dialogue_end(resource: DialogueResource):
	can_move = true
