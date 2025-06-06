class_name Jump
extends State

@export var actor: Entity
@export var animator: AnimationPlayer
@export var jumpIdleAnimation: String

#states
signal toFalling
signal toLanding

func _ready() -> void:
	set_physics_process(false)


func EnterState() -> void:
	set_physics_process(true)
	actor.velocity.y = actor.jumpForce


func _physics_process(_delta: float) -> void:
	actor.HandleGravity(_delta, actor.GravityJump)
	actor.HorizontalMovement(actor.AirSpeed, actor.AirAccelration, actor.AirDeceleration)
	HandleAnimation()
	HandleState()
	actor.move_and_slide()


func ExitState() -> void:
	set_physics_process(false)


func HandleState() -> void:
	if not actor.is_on_floor():
		if actor.velocity.y > 0:
			emit_signal("toFalling")
	else:
		emit_signal("toLanding")


func HandleAnimation() -> void:
	animator.play(jumpIdleAnimation)
