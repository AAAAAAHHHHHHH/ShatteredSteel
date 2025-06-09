# playerSlowdownState.gd
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

# A transition state between Run/Walk to Idle

class_name PlayerSlowdown
extends State

@export var actor: CharacterBody2D
@export var animator: AnimationPlayer

#states
signal to_idle
signal to_walking
signal to_runing
signal to_falling

#animation
@export var runStopIdle : bool = false


func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	
	runStopIdle = false


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.HorizontalMovement(actor.WalkSpeed, actor.StoppingDeceleration, actor.StoppingDeceleration)
	
	actor.handleTerminalVelosityX(_delta)
	
	handleState()
	
	handleAnimation()


func handleState() -> void:
	if actor.is_on_floor():
		if actor.velocity.x != 0:
			if actor.keyRun:
				emit_signal("to_runing")
			elif runStopIdle:
				emit_signal("to_walking")
		else:
			emit_signal("to_idle")
	else:
		emit_signal("to_falling")


func handleAnimation() -> void:
	animator.play("RunStop")
	if runStopIdle:
		animator.play("RunStopIdle")
