# finiteStateMachine.gd
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

# Finite state machine component

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
