# A transition state between Run and Idle or Walk
class_name PlayerSlowdown
extends State

@export var actor: CharacterBody2D
@export var animator: AnimationPlayer

#states
signal toIdle
signal toWalking
signal toRuning
signal toFalling

#animation
@export var runStopIdle : bool = false


func _ready() -> void:
	set_physics_process(false)


func EnterState() -> void:
	set_physics_process(true)
	runStopIdle = false


func ExitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.HorizontalMovement(actor.WalkSpeed, actor.StoppingDeceleration, actor.StoppingDeceleration)
	HandleState()
	HandleAnimation()


func HandleState() -> void:
	if actor.is_on_floor():
		if actor.velocity.x != 0:
			if actor.keyRun:
				emit_signal("toRuning")
			elif runStopIdle:
				emit_signal("toWalking")
		else:
			emit_signal("toIdle")
	else:
		emit_signal("toFalling")


func HandleAnimation() -> void:
	animator.play("RunStop")
	if runStopIdle:
		animator.play("RunStopIdle")
