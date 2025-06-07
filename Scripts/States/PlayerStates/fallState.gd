class_name PlayerFalling
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#States
signal toIdle
signal toWalking
signal toRuning
signal toJumping


func _ready() -> void:
	set_physics_process(false)


func EnterState() -> void:
	set_physics_process(true)


func ExitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.HandleBuffer()
	actor.HandleGravity(_delta, actor.GravityFall)
	HandleState()
	actor.HorizontalMovement(0.0 ,actor.AirDeceleration)
	HandleAnimation()
	
	actor.move_and_slide()


func HandleState() -> void:
	if actor.is_on_floor():
		if actor.velocity.x != 0:
			if actor.keyRun:
				emit_signal("toRuning")
			else:
				emit_signal("toWalking")
		if actor.jumpBufferTimer.time_left > 0:
			actor.jumpForce = actor.FollowUpJumpForce
			actor.jumpStartAnimation = "IdleJumpStart"
			emit_signal("toJumping")
		else:
			emit_signal("toIdle")
	elif actor.coyoteTimer.time_left > 0 and actor.keyJumpPressed:
		actor.jumpForce = actor.FollowUpJumpForce
		actor.jumpStartAnimation = "RunJumpStart"
		emit_signal("toJumping")
	

func HandleAnimation() -> void:
	animator.play("Falling")
	actor.HandleFlipH()
