class_name PlayerJumpState
extends State

var airMovement: float = actor.AirSpeed

@export var actor: Player
@export var animator: AnimationPlayer
@export var jumpIdleAnimation: String

#states
signal toFalling
signal toLanding

func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	
	actor.velocity.y = actor.jumpForce


func _physics_process(_delta: float) -> void:
	actor.handleGravity(_delta, actor.GravityJump)
	
	actor.horizontalMovement(actor.AirSpeed, actor.AirAccelration, actor.AirDeceleration) #TODO: find a way on losing all velosity
	
	handleAnimation()
	
	handleState()
	
	actor.move_and_slide()


func exitState() -> void:
	set_physics_process(false)


func handleState() -> void:
	if not actor.is_on_floor():
		
		if actor.velocity.y > 0:
			emit_signal("toFalling")
			
			
		if not actor.keyJump:
			actor.velocity.y *= actor.VariableJumpMultiplyer
			
	else:
		emit_signal("toLanding")


func handleAnimation() -> void:
	animator.play(jumpIdleAnimation)

func handleAirMovement() -> float:
	
	return airMovement
