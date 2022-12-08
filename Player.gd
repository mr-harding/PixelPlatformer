extends KinematicBody2D
class_name Player


var velocity = Vector2.ZERO
export(int) var JUMP_FORCE = -130
export(int) var RELEASE_FORCE = -70
export(int) var MAX_SPEED = 50
export(int) var ACCELERATION = 10
export(int) var FRICTION = 10
export(int) var GRAVITY = 4

func _ready():
	pass
	
func _physics_process(delta):
	apply_gravity()
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	
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
			velocity.y = JUMP_FORCE
			
	else:
		$AnimatedSprite.animation = "jump_slow"
		if Input.is_action_just_released("ui_up") and velocity.y < -70:
			velocity.y = RELEASE_FORCE
			
		if Input.is_action_pressed("ui_down"):
			velocity.y += 30
			$AnimatedSprite.animation = "jump"
		
func apply_gravity():
	velocity.y += GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)
	
