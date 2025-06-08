class_name FiniteStateMachine 
extends Node

@export var state: State

func _ready() -> void:
	changeState(state)


func changeState(newState: State) -> void:
	if state is State:
		state.exitState()
		newState.enterState()
	state = newState
