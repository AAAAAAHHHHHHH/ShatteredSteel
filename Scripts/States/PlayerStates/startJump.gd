class_name PlayerStartJump
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#States
signal toJumping

func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.horizontalMovement(actor.currentMoveSpeed)
	
	handleAnimation()
	
	handleState()
	
	actor.move_and_slide()


func handleState() -> void:
	emit_signal("toJumping")


func handleAnimation() -> void:
	animator.play(actor.jumpStartAnimation)
	
	actor.handleFlipH()
