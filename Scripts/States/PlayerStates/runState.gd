class_name PlayerRuning
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#states
signal toFalling
signal toWalking
signal toIdle
#signal toSkidding #if the player is going of ove
signal toJumping


func _ready() -> void:
	set_physics_process(false)


func EnterState() -> void:
	set_physics_process(true)
	actor.canLurch = true


func ExitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.HorizontalMovement(actor.RunSpeed)
	HandleState()
	HandleAnimation()
	
	actor.move_and_slide()


func HandleState() -> void:
	if not actor.is_on_floor():
		emit_signal("toFalling")
	elif actor.moveDirectionX != 0 and actor.keyRun:
		if actor.keyJumpPressed and actor.is_on_floor():
			actor.jumpForce = actor.WalkJumpForce
			actor.jumpStartAnimation = "RunJumpStart"
			actor.currentMoveSpeed = actor.RunSpeed
			emit_signal("toJumping")
		else:
			emit_signal("toWalking")
	else:
		emit_signal("toIdle")
	
	#if actor.is_on_floor() and actor.velocity.x >= actor.MaxGroundGrip:
		#emit_signal("toSkidding")

func HandleAnimation() -> void:
	animator.play("Run")
	actor.HandleFlipH()
