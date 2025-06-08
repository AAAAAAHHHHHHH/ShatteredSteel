class_name Player
extends CharacterBody2D

#region Player Variables

# Nodes
## Misc
@onready var sprite: Sprite2D = %Sprite
@onready var collider: CollisionShape2D = %Collider
@onready var jumpBufferTimer: Timer = %JumpBufferTimer
@onready var coyoteTimer: Timer = %CoyoteTimer
@onready var debugInfoHud: DebugInfo = %DebugInfoHud

## Raycasts
@onready var rcBottomLeft: RayCast2D = $Raycasts/WallJump/BottomLeft
@onready var rcBottomRight: RayCast2D = $Raycasts/WallJump/BottomRight

## States
@onready var mainFsm: FiniteStateMachine = %MainFSM
@onready var playerIdle: PlayerIdle = %PlayerIdle
@onready var playerSlowdown: PlayerSlowdown = %PlayerSlowdown
@onready var playerWalking: PlayerWalking = %PlayerWalking
@onready var playerRuning: PlayerRuning = %PlayerRuning
@onready var playerStartJump: PlayerStartJump = %PlayerStartJump
@onready var playerFalling: PlayerFalling = %PlayerFalling
@onready var PlayerJumping: PlayerJumpState = %PlayerJump

# Physics Constants & Varibles
## Forces
const TerminalVelocityY: float = 44000.0 # ~530 km/h
const TerminalVelocityX: float = 16000.0 # ~190 km/h
const DragCoefficientY: float = 0.001 # TODO: fine tune this varibles
const DragCoefficientYUp: float = 0.001
const DragCoefficientX: float = 0.008
const GravityJump: float = 980.0
const GravityFall: float = 1024.0

## Movement 
const WalkSpeed: float = 420.0 
const RunSpeed: float = 1000.0 
const AirSpeed: float = 420.0
const GroundAcceleration: float = 400.0
const GroundDeceleration: float = 360.0
const AirAccelration: float = 10.0
const AirDeceleration: float = 1.0
const WallKickAccelration: float = 4.0
const WallKickDeceleration: float = 5.0
const SidingDeceleration: float = 1.0 

## Jumping
const JumpLurchForce: float = 500.0 # Force that will given during lurch
const FollowUpJumpForce: float = -600.0
const IdleJumpForce: float = -600.0
const WalkJumpForce: float = -500.0
const RunJumpForce: float = -400.0
const VariableJumpMultiplyer: float = 0.95
const WallJumpYSpeedPick: float = 0.0 # Y-speed at which player changes state to fall
const WallJumpVelocity: float = -350
const WallJumpSpeed: float = 350

## Misc
var touchingWall: bool = false
var wallDirection: Vector2
var jumpForce: float = 0.0
var moveDirectionX: float = 0.0
var facing: int = 1
var canLurch: bool = true
var currentMoveSpeed: float = 0.0
var jumpStartAnimation: String = "IdleJumpStart"

# Input variables
## Buffering
const QuickStepBufferTime: float = 0.2 # 12 frames = 12/60
const CoyoteTime: float = 0.1 # 6 frames
const JumpBufferTime: float = 0.15 # 9 frames

## Key Presses
var keyUp: bool = false
var keyDown: bool = false
var keyLeft: bool = false
var keyLurchLeft: bool = false
var keyRight: bool = false
var keyLurchRight: bool = false
var keyRun: bool = false
var keyJump: bool = false
var keyJumpPressed: bool = false

#TODO: imlement bacis combat to the player
var keyGuard: bool = false
var keyVoid: bool = false
var keyQuickStep: bool = false
var keyHeavyAttack: bool = false
var keyAttack: bool = false
var keyLightAttack: bool = false

#endregion

#region Main loop Functions
func _ready() -> void:
	handleSlowdownStateSwitching()
	
	handleJumpingStateSwitching()

func _physics_process(_delta: float) -> void:
	getInputState()
	
	handleBuffer()
	
	handleTerminalVelosityX(_delta)
	
	debugInfoHud.currentPlayerState = str(mainFsm.state)
	debugInfoHud.currentPlayerVelosity = str(jumpBufferTimer.time_left)

#endregion

#region Custom Functions
func isCollidingWithWall() -> bool:
	if rcBottomRight.is_colliding() or rcBottomLeft.is_colliding():
		touchingWall = true
	else:
		touchingWall = false
	
	return touchingWall


func getWallDirection() -> Vector2:
	if rcBottomRight.is_colliding():
		wallDirection = Vector2.RIGHT
	if rcBottomLeft.is_colliding():
		wallDirection = Vector2.LEFT
	
	return wallDirection


func getInputState() -> int:
	keyUp = Input.is_action_pressed("KeyUp")
	keyDown = Input.is_action_pressed("KeyDown")
	keyLeft = Input.is_action_pressed("KeyLeft")
	keyRight = Input.is_action_pressed("KeyRight")
	keyJump = Input.is_action_pressed("KeyJump")
	keyJumpPressed = Input.is_action_just_pressed("KeyJump")
	keyRun = Input.is_action_pressed("KeyRun")
	
	if (keyRight): facing = 1
	if (keyLeft): facing = -1 
	
	return facing


func getDirection() -> float:
	moveDirectionX = Input.get_axis("KeyLeft", "KeyRight")
	return moveDirectionX


func horizontalMovement(moveSpeed: float, acceleration: float = GroundAcceleration, deceleration: float = GroundDeceleration) -> float:
	getDirection()
	
	if moveDirectionX != 0.0:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, deceleration)
	
	return velocity.x 


func handleTerminalVelosityX(delta: float) -> void:
	if velocity.x == 0:
		return
	var _dragForce: float = abs(velocity.x) * DragCoefficientX
	
	if velocity.x > 0:
		velocity.x -= _dragForce * delta
		velocity.x = max(velocity.x, 0.0)
		velocity.x = min(velocity.x, TerminalVelocityX)
	if velocity.x < 0:
		velocity.x += _dragForce * delta
		velocity.x = min(velocity.x, 0.0)
		velocity.x = max(velocity.x, -TerminalVelocityX)


func handleGravity(delta: float, gravity: float = GravityJump) -> float:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if velocity.y > 0 and TerminalVelocityY > 0: # Down
		var _dragForceDown: float = velocity.y * abs(velocity.y) * DragCoefficientY # inversqure law
		velocity.y -= _dragForceDown * delta
		velocity.y = min(velocity.y, TerminalVelocityY)
		
	elif velocity.y < 0 and TerminalVelocityY > 0: # Up
		var _dragForceUp : float = abs(velocity.y) * DragCoefficientYUp 
		velocity.y += _dragForceUp * delta 
	
	return velocity.y

#TODO: implemnt JumpLurch
func handleJumpLurch() -> float:
	#the ablity to change directon rapidly in air
	if canLurch:
		canLurch = false
		return JumpLurchForce
	else:
		return 0.0


func handleBuffer() -> void:
	if keyJumpPressed:
		jumpBufferTimer.start(JumpBufferTime)
	#if keyQuickStep:
		#inputBufferTimer.start(QuickStepBufferTime)


func handleFlipH() -> void:
	sprite.flip_h = (facing == -1)
#endregion

#region State change handling
func handleLanding() -> void: #TODO: add fall damage and a land state
	mainFsm.changeState(playerIdle)


func handleFalling() -> void:
	mainFsm.changeState(playerFalling)


func handleStartJumping() -> void: 
	if is_on_floor():
		if keyJumpPressed or jumpBufferTimer.time_left > 0:
			mainFsm.changeState(playerStartJump)
		elif coyoteTimer.time_left > 0:
			mainFsm.changeState(playerStartJump)


func handleIdleWalkRun() -> void:
	if moveDirectionX != 0:
		if keyRun:
			mainFsm.changeState(playerRuning)
		else:
			mainFsm.changeState(playerWalking)
	else:
		mainFsm.changeState(playerIdle)


func handleWallJumps() -> void:
	getWallDirection()
	if keyJumpPressed or jumpBufferTimer.time_left > 0 and wallDirection != Vector2.ZERO:
		print("WallJump")

#TODO: Triping
func handleSlowdownStateSwitching() -> void:
	playerSlowdown.toRuning.connect(mainFsm.changeState.bind(playerRuning))
	playerSlowdown.toIdle.connect(mainFsm.changeState.bind(playerIdle))
	playerSlowdown.toFalling.connect(mainFsm.changeState.bind(playerFalling))
	playerSlowdown.toWalking.connect(mainFsm.changeState.bind(playerWalking))


func handleJumpingStateSwitching() -> void:
	# Jump Start
	playerStartJump.toJumping.connect(mainFsm.changeState.bind(PlayerJumping))
	
	# Jump but now for real
	PlayerJumping.toFalling.connect(mainFsm.changeState.bind(playerFalling))
#endregion
