extends KinematicBody2D
class_name Player

#STATE MACHINE. in sequence so MOVE is 0, then climb 1 and so on
enum { MOVE, CLIMB }

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = 1
var buffered_jump = false
var coyote_jump = false

export(Resource) var moveData = preload("res://DefaultPlayerMovementData.tres") as PlayerMovementData

onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var JumpBufferTimer: = $JumpBufferTimer
onready var CoyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D
		
	
func _physics_process(delta):
	if is_on_ladder():
		print("is on ladder")
	
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)

		
func move_state(input):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB

	apply_gravity()
	
	
	
	if not horizontal_move(input):
		apply_friction()
		$AnimatedSprite.animation = "idle"
	
	if horizontal_move(input):
		apply_acceleration(input.x)
		$AnimatedSprite.animation = "Run"
		if input.x > 0:
			$AnimatedSprite.flip_h = true
		elif input.x < 0:
			$AnimatedSprite.flip_h = false
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor():
		reset_double_jump()
	
	if can_jump():
		input_jump()
	else:
		input_jump_release()
		fast_fall()
		buffer_jump()
		input_double_jump()
			
	var was_on_floor = is_on_floor()
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		CoyoteJumpTimer.start()

func input_jump_release():
	$AnimatedSprite.animation = "jump_slow"
	if Input.is_action_just_released("ui_up") and velocity.y < -70:
			velocity.y = moveData.RELEASE_FORCE
	
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			SoundPlayer.play_sound(SoundPlayer.JUMP)
			velocity.y = moveData.JUMP_FORCE
			double_jump -= 1
	
func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
			buffered_jump = true
			JumpBufferTimer.start()
	
func fast_fall():
	if Input.is_action_pressed("ui_down"):
			SoundPlayer.play_sound(SoundPlayer.SLAM)
			velocity.y += 30
			$AnimatedSprite.animation = "jump"

func horizontal_move(input):
	return input.x != 0
	
func climb_state(input):
	if not is_on_ladder():
		state = MOVE
		
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "idle"
		
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)		
	
func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")
	
func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path
	
func input_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
			SoundPlayer.play_sound(SoundPlayer.JUMP)
			velocity.y = moveData.JUMP_FORCE
			buffered_jump = false
	
func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMP_COUNT

func can_jump():
	return is_on_floor() or coyote_jump

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true
		
func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)
	
func _on_JumpBufferTimer_timeout():
	buffered_jump = false # Replace with function body.


func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false
