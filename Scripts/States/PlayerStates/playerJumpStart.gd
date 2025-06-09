# playerRunState.gd
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

# Handles player runing

class_name PlayerStartJump
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#States
signal to_jumping

func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.handleHorizontalMovement(actor.currentMoveSpeed)
	
	actor.handleTerminalVelosityX(_delta)
	
	handleAnimation()
	
	handleState()
	
	actor.move_and_slide()


func handleState() -> void:
	emit_signal("to_jumping")


func handleAnimation() -> void:
	animator.play(actor.jumpStartAnimation)
	
	actor.handleFlipH()
