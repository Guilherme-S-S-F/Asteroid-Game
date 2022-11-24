extends Area2D

export var speed = 200

func _process(delta):
	# move the bullet by the frame time
	position += transform.x * speed * delta


func _on_Timer_timeout():
	queue_free()
	

