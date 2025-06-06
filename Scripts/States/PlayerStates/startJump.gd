class_name PlayerStartJump
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#States
signal toJumping


func _ready() -> void:
	set_physics_process(false)


func EnterState() -> void:
	set_physics_process(true)


func ExitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.HorizontalMovement(actor.currentMoveSpeed)
	HandleAnimation()
	actor.move_and_slide()


func HandleState() -> void:
	emit_signal("toJumping")


func HandleAnimation() -> void:
	animator.play(actor.jumpStartAnimation)
	actor.HandleFlipH()
