class_name PlayerWalking
extends State

@export var actor: Player
@export var animator: AnimationPlayer


func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	actor.jumpForce = actor.WalkJumpForce
	actor.jumpStartAnimation = "WalkJumpStart"
	actor.currentMoveSpeed = actor.RunSpeed
	actor.canLurch = true


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.horizontalMovement(actor.WalkSpeed)
	
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


func handleAnimation() -> void:
	if actor.velocity.x == 0.0:
		animator.play("IdleStanding")
		actor.handleFlipH()
	else:
		animator.play("Walk")
		actor.handleFlipH()
