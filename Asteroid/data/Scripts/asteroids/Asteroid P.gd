extends Asteroid

func _ready():
	pass	

func active_particle():
	var particle = particle_prefab.instance() as Node2D
	
	particle.position = position
	
	get_parent().add_child(particle)
		
func _on_Area2D_area_entered(area):
	if area.is_in_group("projectile"):
		emit_signal("score_up",points)
		active_particle()
		area.queue_free()
		queue_free()
