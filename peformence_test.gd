extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	animated_sprite_2d.play("Idle")
