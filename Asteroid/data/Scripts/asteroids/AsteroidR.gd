extends RigidBody2D
class_name AsteroidR

signal score_up(score)

export var rotation_speed: float = 1.2
var rotation_dir

export var speed : float = 10
export var points : int
onready var dir = Vector2(rand_range(-1,1),rand_range(-1,1))

func _ready():
	rotation_dir = rand_range(-1,1)
	if rotation_dir == 0:
		rotation_dir = 1
		
	dir = dir.normalized()

func _process(delta):
	border_teleporter()
	
func _physics_process(delta):
	rotation += rotation_dir * rotation_speed * delta
	move()

func move():	
	apply_impulse(Vector2(0,0),dir)


func border_teleporter():
	if position.x <= -120:
		position.x = 110
	elif position.x >= 120:
		position.x = -110
	elif position.y <= -120:
		position.y = 110
	elif position.y >= 120:
		position.y = -110

func change_direction():
	#dir.x *= -1
	#dir.y *= -1
	pass


	
