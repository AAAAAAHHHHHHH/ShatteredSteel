class_name PlayerFalling
extends State

@export var actor: Player
@export var animator: AnimationPlayer


func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	actor.jumpForce = actor.FollowUpJumpForce
	actor.jumpStartAnimation = "RunJumpStart"


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.handleBuffer()
	
	actor.handleGravity(_delta, actor.GravityFall)
	
	handleState()
	
	actor.horizontalMovement(actor.currentMoveSpeed ,actor.AirAccelration, actor.AirDeceleration)
	
	handleAnimation()
	
	actor.move_and_slide()


func handleState() -> void:
	if actor.is_on_floor():
		actor.handleIdleWalkRun()
	else:
		actor.handleFalling()
	actor.handleStartJumping()
	

func handleAnimation() -> void:
	animator.play("Falling")
