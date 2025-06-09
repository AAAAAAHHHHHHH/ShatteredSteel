# playerLandState.gd
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

# Handles player landing and hoping

class_name PlayerLanding
extends State

@export var actor: Player
@export var animator: AnimationPlayer
@export var canChangeStates: bool


func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	canChangeStates = false


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.handleHorizontalMomentum(actor.SlidingDecelaration)
	
	actor.handleTerminalVelosityX(_delta)
	
	handleAnimation()
	
	handleState()
	
	actor.move_and_slide()


func handleState() -> void:
	actor.handleStartJumping()
	if canChangeStates:
		actor.handleIdleWalkRun()
		if not actor.is_on_floor():
			actor.coyoteTimer.start(actor.CoyoteTime)
			actor.handleFalling()



func handleAnimation() -> void:
	animator.play("LowLand")
	
	actor.handleFlipH()
