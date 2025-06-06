class_name Player
extends CharacterBody2D

#region Player Variables

# Nodes
@onready var sprite: Sprite2D = %Sprite
@onready var collider: CollisionShape2D = %Collider
#@onready var animator: AnimationPlayer = %Animator
@onready var JumpBufferTimer: Timer = %JumpBuffer
@onready var coyoteTimer: Timer = %CoyoteTimer

@onready var mainFsm: FiniteStateMachine = %MainFSM
@onready var playerIdle: PlayerIdle = %PlayerIdle
@onready var playerSlowdown: PlayerSlowdown = %PlayerSlowdown
@onready var playerWalking: PlayerWalking = %PlayerWalking
@onready var playerRuning: PlayerRuning = %PlayerRuning
@onready var playerStartJump: PlayerStartJump = %PlayerStartJump
@onready var playerFalling: PlayerFalling = %PlayerFalling
@onready var PlayerJumping: PlayerJumpState = %PlayerJump

# Physics variables
const WalkSpeed: float = 150.0
const RunSpeed: float = 350.0
const QuickStepBufferTime: float = 0.2 # 12 frames = 12/60

const AirSpeed: float = 50.0
const AirAccelration: float = 5.0
const AirDeceleration: float = 1.0
const Acceleration: float = 50.0
const Deceleration: float = 40.0
const StoppingDeceleration: float = 1.0
const TerminalVelocityY: float = 44345.0 # ~530 km/h
const TerminalVelocityX: float = 15897.0 # ~190 km/h
const DragCoefficientY: float = 0.001 # TODO: fine tune this varibles
const DragCoefficientYUp: float = 0.001
const DragCoefficientX: float = 0.008

const MaxJumps: int = 2
const JumpLurchForce: float = 500.0 
const FollowUpJumpForce: float = -300
const IdleJumpForce: float = -400.0
const WalkJumpForce: float = -500.0
const RunJumpForce: float = -600.0

const GravityJump: float = 980.0
const GravityFall: float = 1024.0
const VariableJumpMultiplyer: float = 0.95
const JumpBufferTime: float = 0.15 # 9 frames
const CoyoteTime: float = 0.05 # 3 frames

# Physical Varibles
var jumps: int = 0
var jumpForce: float = 0.0
var moveDirectionX: float = 0.0
var facing: int = 1
var canLurch: bool = true

var jumpStartAnimation: String = "IdleJumpStart"
var currentMoveSpeed: float

# Input variables
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
	
	#Idle state Switching
	HandleIdleStateSwitching()
	
	# Walking state Switching
	HandleWalkStateSwitching()
	
	# Running state Switching
	HandleRunStateSwitching()
	
	#Falling state Switching
	HandleFallStateSwitching()
	
	# Slowdown state Switching
	HandleSlowdownStateSwitching()
	
	# Jump transitions
	HandleJumpingStateSwitching()

func _physics_process(_delta: float) -> void:
	GetInputState()
	HandleBuffer()
	HandleTerminalVelosityX(_delta)

#endregion

#region Custom Functions

func GetInputState() -> int:
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


func GetDircetion() -> float:
	moveDirectionX = Input.get_axis("KeyLeft", "KeyRight")
	return moveDirectionX


func HorizontalMovement(moveSpeed: float, acceleration: float = Acceleration, deceleration: float = Deceleration) -> float:
	GetDircetion()
	
	if moveDirectionX != 0.0:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
	
	return velocity.x 


func HandleTerminalVelosityX(delta: float) -> void:
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


func HandleGravity(delta: float, gravity: float = GravityJump) -> float:
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


func HandleJump() -> void:
	if jumps < MaxJumps:
		if keyJumpPressed:
			jumps += 1
			velocity.y = jumpForce
		if JumpBufferTimer.time_left > 0:
			JumpBufferTimer.stop()

#TODO: implemnt JumpLurch
func HandleJumpLurch() -> float:
	#the ablity to change directon rapidly in air
	if canLurch:
		canLurch = false
		return JumpLurchForce
	else:
		return 0.0


func HandleBuffer() -> void:
	if keyJumpPressed:
		JumpBufferTimer.start(JumpBufferTime)
	#if keyQuickStep:
		#inputBufferTimer.start(QuickStepBufferTime)


func HandleFlipH() -> void:
	sprite.flip_h = (facing == -1)
#endregion

#region State change handling
func HandleIdleStateSwitching() -> void:
	playerIdle.toFalling.connect(mainFsm.ChangeState.bind(playerFalling))
	playerIdle.toWalking.connect(mainFsm.ChangeState.bind(playerWalking))
	playerIdle.toRuning.connect(mainFsm.ChangeState.bind(playerRuning))
	playerIdle.toJumping.connect(mainFsm.ChangeState.bind(playerStartJump))


func HandleWalkStateSwitching() -> void:
	playerWalking.toIdle.connect(mainFsm.ChangeState.bind(playerIdle))
	playerWalking.toFalling.connect(mainFsm.ChangeState.bind(playerFalling))
	playerWalking.toRuning.connect(mainFsm.ChangeState.bind(playerRuning))
	playerWalking.toJumping.connect(mainFsm.ChangeState.bind(playerStartJump))


func HandleRunStateSwitching() -> void:
	playerRuning.toIdle.connect(mainFsm.ChangeState.bind(playerIdle))
	playerRuning.toFalling.connect(mainFsm.ChangeState.bind(playerFalling))
	playerRuning.toJumping.connect(mainFsm.ChangeState.bind(playerStartJump))


func HandleFallStateSwitching() -> void:
	playerFalling.toIdle.connect(mainFsm.ChangeState.bind(playerIdle))
	playerFalling.toWalking.connect(mainFsm.ChangeState.bind(playerWalking))
	playerFalling.toRuning.connect(mainFsm.ChangeState.bind(playerRuning))
	playerFalling.toJumping.connect(mainFsm.ChangeState.bind(playerStartJump))

#TODO: Triping
func HandleSlowdownStateSwitching() -> void:
	playerSlowdown.toRuning.connect(mainFsm.ChangeState.bind(playerRuning))
	playerSlowdown.toIdle.connect(mainFsm.ChangeState.bind(playerIdle))
	playerSlowdown.toFalling.connect(mainFsm.ChangeState.bind(playerFalling))
	playerSlowdown.toWalking.connect(mainFsm.ChangeState.bind(playerWalking))


func HandleJumpingStateSwitching() -> void:
	# Jump Start
	playerStartJump.toJumping.connect(mainFsm.ChangeState.bind(PlayerJumping))
	
	# Jump but now for real
	PlayerJumping.toFalling.connect(mainFsm.ChangeState.bind(playerFalling))
#endregion
