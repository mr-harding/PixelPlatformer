extends KinematicBody2D
class_name Player

#STATE MACHINE. in sequence so MOVE is 0, then climb 1 and so on
enum { MOVE, CLIMB }

var velocity = Vector2.ZERO
var state = MOVE

export(Resource) var moveData

onready var animatedSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck
	
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
	
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			velocity.y = moveData.JUMP_FORCE
			
	else:
		$AnimatedSprite.animation = "jump_slow"
		if Input.is_action_just_released("ui_up") and velocity.y < -70:
			velocity.y = moveData.RELEASE_FORCE
			
		if Input.is_action_pressed("ui_down"):
			velocity.y += 30
			$AnimatedSprite.animation = "jump"
	
func climb_state(input):
	if not is_on_ladder():
		state = MOVE
		
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "idle"
		
	velocity = input * 50
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
	
