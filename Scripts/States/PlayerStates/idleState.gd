class_name PlayerIdle
extends State

@export var actor: Player
@export var animator: AnimationPlayer


func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	actor.currentMoveSpeed = 0.0
	actor.jumpForce = actor.IdleJumpForce
	actor.jumpStartAnimation = "IdleJumpStart"
	actor.canLurch = true


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.getDirection()
	
	actor.horizontalMovement(0.0)
	
	handleState()
	
	handleAnimation()


func handleState() -> void:
	if actor.is_on_floor():
		actor.handleIdleWalkRun()
	else:
		actor.coyoteTimer.start(actor.CoyoteTime)
		actor.handleFalling()
	actor.handleStartJumping()


func handleAnimation() -> void:
	animator.play("IdleStanding")
	actor.handleFlipH()
