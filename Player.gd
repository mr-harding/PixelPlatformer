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
	if input.x == 0:
		apply_friction()
		$AnimatedSprite.animation = "idle"
	else:
		apply_acceleration(input.x)
		$AnimatedSprite.animation = "Run"
		if input.x > 0:
			$AnimatedSprite.flip_h = true
		elif input.x < 0:
			$AnimatedSprite.flip_h = false
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor() or coyote_jump:
		double_jump = moveData.DOUBLE_JUMP_COUNT
		if Input.is_action_just_pressed("ui_up") or buffered_jump:
			velocity.y = moveData.JUMP_FORCE
			buffered_jump = false
		
	else:
		$AnimatedSprite.animation = "jump_slow"
		if Input.is_action_just_released("ui_up") and velocity.y < -70:
			velocity.y = moveData.RELEASE_FORCE
			
		if Input.is_action_pressed("ui_down"):
			velocity.y += 30
			$AnimatedSprite.animation = "jump"
			
		if Input.is_action_just_pressed("ui_up"):
			buffered_jump = true
			JumpBufferTimer.start()
#
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			velocity.y = moveData.JUMP_FORCE
			double_jump -= 1
			
	var was_on_floor = is_on_floor()
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		CoyoteJumpTimer.start()
	
func climb_state(input):
	if not is_on_ladder():
		state = MOVE
		
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "idle"
		
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)		

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
