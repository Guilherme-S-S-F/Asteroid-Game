extends Asteroid

onready var asteroids_prefab  = [
preload("res://data/Prefabs/asteroids/Asteroid P1.tscn"),
preload("res://data/Prefabs/asteroids/Asteroid P2.tscn")
]

func _ready():
	pass
	
func fragment_asteroid():	
	# Instanciate two new asteroid
	var asteroidA = asteroids_prefab[rand_range(0,1)].instance()
	var asteroidB = asteroids_prefab[rand_range(0,1)].instance()
	
	var particle = particle_prefab.instance() as Node2D
	
	particle.position = position
	
	# spawn the asteroids in a area
	asteroidA.position = Vector2(rand_range(position.x -10,position.x +10),
	rand_range(position.y -10,position.y +10))	
	asteroidB.position = Vector2(rand_range(position.x -10,position.x +10),
	rand_range(position.y -10,position.y +10))
	
	asteroidA.add_torque(2)
	asteroidB.add_torque(2)
	
	# Connect the signal "score_up" to the Game script's function "score"
	asteroidA.connect("score_up",get_tree().get_root().find_node("World",true,false),"score")
	asteroidB.connect("score_up",get_tree().get_root().find_node("World",true,false),"score")
	
	get_parent().add_child(particle)
	get_parent().add_child(asteroidA)
	get_parent().add_child(asteroidB)


func _on_Area2D_area_entered(area):	
	# Detect if a bullet collided with the collider
	if area.is_in_group("projectile"):
		fragment_asteroid()
		# send the signal "score_up"
		emit_signal("score_up",points)
		area.queue_free()
		queue_free()
