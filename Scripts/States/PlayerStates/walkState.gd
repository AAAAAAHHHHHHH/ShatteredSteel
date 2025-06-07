class_name PlayerWalking
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#states
signal toFalling
signal toRuning
signal toIdle
signal toJumping

func _ready() -> void:
	set_physics_process(false)


func EnterState() -> void:
	set_physics_process(true)
	actor.canLurch = true


func ExitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.HorizontalMovement(actor.WalkSpeed)
	HandleState()
	
	actor.move_and_slide()
	HandleAnimation()

func HandleState() -> void:
	if not actor.is_on_floor():
		actor.coyoteTimer.start(actor.CoyoteTime)
		emit_signal("toFalling")
	elif actor.moveDirectionX != 0:
		if actor.keyRun:
			emit_signal("toRuning")
		else:
			if actor.keyJumpPressed:
				actor.currentMoveSpeed = actor.WalkSpeed
				actor.jumpForce = actor.WalkJumpForce
				actor.jumpStartAnimation = "WalkJumpStart"
				emit_signal("toJumping")
	else:
		emit_signal("toIdle")


func HandleAnimation() -> void:
	if actor.velocity.x == 0.0:
		animator.play("IdleStanding")
		actor.HandleFlipH()
	else:
		animator.play("Walk")
		actor.HandleFlipH()
