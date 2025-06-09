# playerFallState.gd
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

# Handles player falling

class_name PlayerFalling
extends State

@export var actor: Player
@export var animator: AnimationPlayer

func _ready() -> void:
	set_physics_process(false)


func enterState() -> void:
	set_physics_process(true)


func exitState() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.handleBuffer()
	
	actor.handleGravity(_delta, actor.GravityFall)
	
	actor.handleHorizontalMomentum()
	
	actor.move_and_slide()
	
	handleState()
	
	handleAnimation()


func handleState() -> void:
	if actor.is_on_floor():
		actor.handleLanding()
	

func handleAnimation() -> void:
	animator.play("Falling")
