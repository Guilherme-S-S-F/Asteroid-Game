extends RigidBody2D
class_name Asteroid

signal score_up(score)

export var rotation_speed: float = 1.2
var rotation_dir


export var points : int

onready var particle_prefab = preload("res://data/Prefabs/asteroids/ParticleEmitter.tscn")
# give a random direction to move
onready var dir = Vector2(rand_range(-1,1),rand_range(-1,1))

func _ready():
	# give a direction to rotate
	rotation_dir = rand_range(-1,1)
	if rotation_dir == 0:
		rotation_dir = 1
	
	# normalize the movement direction
	dir = dir.normalized()

func _process(delta):
	border_teleporter()
	
func _physics_process(delta):
	# rotate the asteroid
	rotation += rotation_dir * rotation_speed * delta
	move()

func move():
	# move him with the rigidbody2D	
	apply_impulse(Vector2(0,0),dir)

func border_teleporter():
	# teleport the asteroid when it goes out the screen
	if position.x <= -120:
		position.x = 110
	elif position.x >= 120:
		position.x = -110
	elif position.y <= -120:
		position.y = 110
	elif position.y >= 120:
		position.y = -110



	
