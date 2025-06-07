class_name DebugInfo
extends CanvasLayer

@export var currentPlayerState: String
@export var currentPlayerVelosity: String
@onready var drawCalls: Label = %DrawCalls
@onready var frameTimes: Label = %FrameTimes
@onready var vram: Label = %Vram
@onready var fps: Label = %Fps
@onready var outState: Label = %PlayerState
@onready var outVelosity: Label = %PlayerVelosityX
