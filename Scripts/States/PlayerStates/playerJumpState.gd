# playerJumpStart.gd
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

# Handles player jumping

class_name PlayerJumpState
extends State

@export var actor: Player
@export var animator: AnimationPlayer

#states
signal to_falling
signal toLanding

func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)
	print(actor.velocity.x)
	#actor.velocity.x *= actor.xJumpFactor
	actor.velocity.y = actor.jumpForce


func _physics_process(_delta: float) -> void:
	actor.handleGravity(_delta, actor.GravityJump)
	
	actor.handleHorizontalMomentum() #TODO: find a way on losing all velosity
	
	actor.handleTerminalVelosityX(_delta)
	
	handleAnimation()
	
	handleState()
	
	actor.move_and_slide()


func exitState() -> void:
	set_physics_process(false)


func handleState() -> void:
	if not actor.is_on_floor():
		
		if actor.velocity.y > 0:
			emit_signal("to_falling")
			
			
		if not actor.keyJump:
			actor.velocity.y *= actor.VariableJumpMultiplyer
			
	else:
		emit_signal("toLanding")


func handleAnimation() -> void:
	animator.play(actor.jumpIdleAnimation)
