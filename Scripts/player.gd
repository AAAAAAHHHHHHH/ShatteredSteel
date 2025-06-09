# player.gd
#
# This file is part of Shattered Steel.
#
# Shattered Steel is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Shattered Steel is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Shattered Steel.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright (C) 2025 TeaOverDose

# Player constants and functions/definitions

class_name Player
extends CharacterBody2D
#NOTE: for code sytling read codeStyling.md

#region =================== Player Variables ===================
# Nodes
## Misc
@onready var sprite: Sprite2D = %Sprite
@onready var collider: CollisionShape2D = %Collider
@onready var coyoteTimer: Timer = %CoyoteTimer
@onready var debugInfoHud: DebugInfo = %DebugInfoHud
@onready var bufferTimer: Timer = $Timers/BufferTimer

## Raycasts
@onready var RCBottomLeft: RayCast2D = $Raycasts/WallJump/BottomLeft
@onready var RCBottomRight: RayCast2D = $Raycasts/WallJump/BottomRight

## FSMs
@onready var mainFsm: FiniteStateMachine = %MainFSM
@onready var playerIdle: PlayerIdle = %PlayerIdle
@onready var playerSlowdown: PlayerSlowdown = %PlayerSlowdown
@onready var playerWalking: PlayerWalking = %PlayerWalking
@onready var playerRuning: PlayerRuning = %PlayerRuning
@onready var playerStartJump: PlayerStartJump = %PlayerStartJump
@onready var playerJumping: PlayerJumpState = %PlayerJump
@onready var playerFalling: PlayerFalling = %PlayerFalling
@onready var playerLanding: PlayerLanding = %PlayerLanding

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
const GroundAcceleration: float = 400.0
const GroundDeceleration: float = 360.0
const AirDeceleration: float = 1.0
const WallKickAccelration: float = 4.0
const WallKickDeceleration: float = 5.0
const SlidingDecelaration: float = 10
const SkiddingDeceleration: float = 1.0 

## Jumping
const JumpLurchForce: float = 500.0 # Force that will given during lurch
const FollowUpJumpForce: float = -600.0
const IdleJumpForce: float = -600.0
const WalkJumpForce: float = -500.0
const RunJumpForce: float = -400.0
const WalkXJumpFactor: float = 0.7 #actor.velocity.x *= actor.xJumpFactor
const RunXJumpFactor: float = 0.9
const WalkHopMultiplier: float = 1.5
const RunHopMultiplier: float = 2.0
const VariableJumpMultiplyer: float = 0.95
const WallJumpYSpeedPick: float = 0.0 # Y-speed at which player changes state to fall
const WallJumpVelocity: float = -350
const WallJumpSpeed: float = 350

## Misc
var isBlockedByWall: bool = false
var wallDirection: Vector2
var moveDirectionX: float = 0.0
var facing: int = 1
var canLurch: bool = true
var currentMoveSpeed: float = 0.0

## Jump
var jumpForce: float = 0.0
var jumpStartAnimation: String = "IdleJumpStart"
var jumpIdleAnimation: String = "IdleJump"
var xJumpFactor: float = false
var jumpBuffered: bool = false
var hopMulitplier: float = 0.0 #negates the suddent speed loss when hopinp

# Input variables
## Buffering
const CoyoteTime: float = 0.1 # 6 frames = 6/60
const BufferTime: float = 0.15 # 9 frames 

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

#region =================== Main loop Functions ===================
func _ready() -> void:
	handleSlowdownStateSwitching()
	
	handleJumpingStateSwitching()

func _physics_process(_delta: float) -> void:
	getInputState()
	
	handleBuffer()
	
	getStateVaribles()
	
	getDirection()
	
	isMovingIntoWall()
	
	#handleBuffer()
	
	#handleTerminalVelosityX(_delta)
	
	debugInfoHud.currentPlayerState = str(mainFsm.state)
	debugInfoHud.currentPlayerVelosity = str(jumpBuffered)#str(roundf(velocity.x)) + ", " + str(roundf(velocity.y))
#endregion

#region =================== Custom Functions ===================
func isMovingIntoWall() -> bool:
	isBlockedByWall = false
	if facing == 1: # Facing Right
		if RCBottomRight.is_colliding(): 
			isBlockedByWall = true
		
	elif facing == -1: # Facing Left
		if RCBottomLeft.is_colliding(): 
			isBlockedByWall = true
		
	if isBlockedByWall and moveDirectionX == facing:
		return true 
	else:
		return false


func getWallDirection() -> Vector2:
	if RCBottomRight.is_colliding():
		wallDirection = Vector2.RIGHT
	if RCBottomLeft.is_colliding():
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


func handleHorizontalMovement(moveSpeed: float, acceleration: float = GroundAcceleration, deceleration: float = GroundDeceleration,) -> float:
	if moveDirectionX != 0.0:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, moveDirectionX * moveSpeed, deceleration)
	
	return velocity.x 


func handleHorizontalMomentum(deceleration: float = AirDeceleration) -> float:
	velocity.x = move_toward(velocity.x, 0.0, deceleration)
	
	return velocity.x


func handleTerminalVelosityX(delta: float) -> float:
	if velocity.x == 0.0:
		return 0.0
	var _dragForce: float = abs(velocity.x) * DragCoefficientX
	
	if velocity.x > 0:
		velocity.x -= _dragForce * delta
		velocity.x = max(velocity.x, 0.0)
		velocity.x = min(velocity.x, TerminalVelocityX)
	if velocity.x < 0:
		velocity.x += _dragForce * delta
		velocity.x = min(velocity.x, 0.0)
		velocity.x = max(velocity.x, -TerminalVelocityX)
	
	return velocity.x


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


func handleBuffer() -> bool:
	if keyJumpPressed:
		bufferTimer.start(BufferTime)
	
	if bufferTimer.time_left > 0:
		jumpBuffered = true
	else: 
		jumpBuffered = false
	
	return jumpBuffered


func handleFlipH() -> void:
	sprite.flip_h = (facing == -1)
#endregion

#region =================== State change handling ===================
func handleLanding() -> void: #TODO: add fall damage and a land state
	mainFsm.changeState(playerLanding)


func handleFalling() -> void:
	mainFsm.changeState(playerFalling)


func getStateVaribles() -> void:
	if mainFsm.state == playerIdle:
		canLurch = true # NOTE Lurching on ground is imposible. it's just a reset value.
		currentMoveSpeed = 0.0
		jumpStartAnimation = "IdleJumpStart"
		jumpIdleAnimation = "IdleJump"
		jumpForce = IdleJumpForce
		xJumpFactor = 1.0
		hopMulitplier = 0.0
	
	if mainFsm.state == playerWalking:
		canLurch = true
		currentMoveSpeed = WalkSpeed
		jumpStartAnimation = "WalkJumpStart"
		jumpIdleAnimation = "WalkJump"
		jumpForce = WalkJumpForce
		xJumpFactor = WalkXJumpFactor
		hopMulitplier = WalkHopMultiplier
	
	if mainFsm.state == playerRuning:
		canLurch = true
		currentMoveSpeed = RunSpeed
		jumpStartAnimation = "RunJumpStart"
		jumpIdleAnimation = "RunJump"
		jumpForce = RunJumpForce
		xJumpFactor = RunXJumpFactor
		hopMulitplier = RunHopMultiplier
	
	if mainFsm.state == playerStartJump:
		pass
	
	if mainFsm.state == playerJumping:
		currentMoveSpeed = 0.0
	
	if mainFsm.state == playerFalling:
		#TODO: Make the animations
		jumpForce = FollowUpJumpForce #TODO fix the lose velosity bug
		xJumpFactor = 1.0


func handleStartJumping() -> void: 
	if is_on_floor():
		if keyJumpPressed or jumpBuffered:
			mainFsm.changeState(playerStartJump)
			bufferTimer.stop()
		elif coyoteTimer.time_left > 0:
			mainFsm.changeState(playerStartJump)


func handleIdleWalkRun() -> void:
	if is_on_floor() or isBlockedByWall:
		mainFsm.changeState(playerIdle)
		
	if is_on_floor() and moveDirectionX != 0 and not isBlockedByWall:
		if keyRun:
			mainFsm.changeState(playerRuning)
		else:
			mainFsm.changeState(playerWalking)


func handleWallJumps() -> void:
	getWallDirection()
	if keyJumpPressed and wallDirection != Vector2.ZERO:
		print("WallJump")

#TODO: Triping
func handleSlowdownStateSwitching() -> void:
	playerSlowdown.to_runing.connect(mainFsm.changeState.bind(playerRuning))
	playerSlowdown.to_idle.connect(mainFsm.changeState.bind(playerIdle))
	playerSlowdown.to_falling.connect(mainFsm.changeState.bind(playerFalling))
	playerSlowdown.to_walking.connect(mainFsm.changeState.bind(playerWalking))


func handleJumpingStateSwitching() -> void:
	# Jump Start
	playerStartJump.to_jumping.connect(mainFsm.changeState.bind(playerJumping))
	
	# Jump but now for real
	playerJumping.to_falling.connect(mainFsm.changeState.bind(playerFalling))
#endregion
