class_name PlayerIdle
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#states
signal toFalling
signal toWalking
signal toRuning
signal toJumping


func _ready() -> void:
	set_physics_process(false)


func EnterState() -> void:
	set_physics_process(true)
	actor.canLurch = true


func ExitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.GetDircetion()
	actor.HorizontalMovement(0.0)
	HandleState()
	HandleAnimation()


func HandleState() -> void:
	if not actor.is_on_floor():
		emit_signal("toFalling")
	elif actor.moveDirectionX != 0:
		if actor.keyRun:
			emit_signal("toRuning")
		else:
			emit_signal("toWalking")
		
	if actor.keyJumpPressed and actor.is_on_floor():
		actor.currentMoveSpeed = 0.0
		actor.jumpForce = actor.IdleJumpForce
		actor.jumpStartAnimation = "IdleJumpStart"
		emit_signal("toJumping")


func HandleAnimation() -> void:
	animator.play("StandingIdle")
	actor.HandleFlipH()
