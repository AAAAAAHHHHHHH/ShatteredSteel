# debugInfoHud.gd
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

# Handle debud hud

extends Control

@onready var Info: DebugInfo = $".."

func _physics_process(delta: float) -> void:
	
	BasicPreformenceStats(delta)
	Info.outState.text = Info.currentPlayerState
	Info.outVelosity.text = Info.currentPlayerVelosity

func BasicPreformenceStats(_delta: float) -> void:
	Info.drawCalls.text = "Draw Calls: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	Info.frameTimes.text = "Frame Times: " + str(snapped(_delta * 1000, 0.1)) + "ms"
	Info.vram.text = "VRAM: " + str(roundf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0))) 
	Info.fps.text = "FPS: " + str(Engine.get_frames_per_second())
