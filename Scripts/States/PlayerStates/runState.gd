class_name PlayerRuning
extends State

@export var actor: Player
@export var animator: AnimationPlayer


func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	actor.jumpForce = actor.RunJumpForce
	actor.jumpStartAnimation = "RunJumpStart"
	actor.currentMoveSpeed = actor.RunSpeed
	actor.canLurch = true


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.horizontalMovement(actor.RunSpeed)
	
	handleState()
	
	actor.move_and_slide()
	
	handleAnimation()



func handleState() -> void:
	if actor.is_on_floor():
		actor.handleIdleWalkRun()
	else:
		actor.coyoteTimer.start(actor.CoyoteTime)
		actor.handleFalling()
	actor.handleStartJumping()
	#if actor.is_on_floor() and actor.velocity.x >= actor.MaxGroundGrip:
		#emit_signal("toSkidding")

func handleAnimation() -> void:
	if actor.velocity.x == 0.0:
		animator.play("IdleStanding")
		actor.handleFlipH()
	else:
		animator.play("Run")
		actor.handleFlipH()
