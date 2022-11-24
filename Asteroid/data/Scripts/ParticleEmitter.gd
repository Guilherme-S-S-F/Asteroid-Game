extends Node2D

func _ready():
	$AudioStreamPlayer.play()
	get_node("AnimationPlayer").play("Explode")
	yield($AnimationPlayer,"animation_finished")
	queue_free()
