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
