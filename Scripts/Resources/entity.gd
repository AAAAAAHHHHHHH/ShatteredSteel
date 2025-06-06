class_name Entity
extends CharacterBody2D

#region
# Physics variables
#const WalkSpeed: float = 150.0
#const RunSpeed: float = 350.0

#const AirSpeed: float = 50.0
#const AirAccelration: float = 5.0
#const AirDeceleration: float = 1.0
#const Acceleration: float = 50.0
#const Deceleration: float = 40.0
#const StoppingDeceleration: float = 1.0

#const JumpLurchForce: float = 500.0 
#const IdleJumpForce: float = -300.0
#const WalkJumpForce: float = -350.0
#const RunJumpForce: float = -400.0
#endregion

const AirAccelration: float = 5.0
const AirDeceleration: float = 1.0
const GravityJump: float = 980.0
const GravityFall: float = 1000.0
const MaxFallSpeed: float = 450.0

# Physical Varibles
var jumpForce: float = 0.0
var moveDirectionX: float = 0.0
var facing: int = 1

# AI varibles 
var reactionTime: float = 0.25
var adrenalineLevel: int = 0 #0 to 255
var adrenalineFactor: Array = [1.0, 0.95, 0.9, 0.85, 0.8, 0.75, 0.70, 0.65, 0.60, 0.55, 0.50,] # the amount by reaction time dercrece at given adrenaline intervales 

func GetDircetion() -> float:
	#TODO: do a more robust system.
	moveDirectionX = Input.get_axis("KeyLeft", "KeyRight")
	return moveDirectionX


func HorizontalMovement(moveSpeed: float, acceleration: float, deceleration: float) -> float:
	GetDircetion()
	
	if moveDirectionX != 0.0:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
	
	return velocity.x 


func HandleGravity(_delta: float, gravity: float = GravityJump) -> float:
	if not is_on_floor():
		velocity.y += gravity * _delta
	
	return velocity.y
