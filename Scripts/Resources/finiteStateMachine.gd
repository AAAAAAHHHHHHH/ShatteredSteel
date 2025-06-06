class_name FiniteStateMachine 
extends Node

@export var state: State

func _ready() -> void:
	ChangeState(state)


func ChangeState(newState: State) -> void:
	if state is State:
		state.ExitState()
		newState.EnterState()
	state = newState
