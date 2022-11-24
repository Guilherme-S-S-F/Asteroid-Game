extends KinematicBody2D
class_name Ship

# Export variables
export (int) var acceleration = 15
export (int) var max_speed = 50
export (float) var rotation_speed = 3.5

export (float) var friction_weight = 0.02

export (float) var fire_rate = 0.4

onready var particle_prefab = preload("res://data/Prefabs/ShipParticle.tscn")

signal explode()
signal restore_life()

# Variables
var input_vector : Vector2
var velocity : Vector2

var rotation_dir : int

var can_fire = false

func _ready():
	# Play the spawn effect
	$AnimationPlayer.play("Flash")
	# Connect signal "explode" to the function "remove-life" from the Game script
	connect("explode",get_tree().get_root().find_node("World",true,false),"remove_life")
	connect("restore_life",get_tree().get_root().find_node("World",true,false),"restore_health")
	
func _physics_process(delta):
	border_teleporter()
	move_ship(delta)

	
func move_ship(delta):
	# get a direction strength based in the keyboards input up and down
	input_vector.x = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	# Set a rotation direction
	rotation_dir = 0	
	if Input.is_action_pressed("ui_right"):
		rotation_dir += 1	
	if Input.is_action_pressed("ui_left"):
		rotation_dir += -1
		
	# Give it velocity based on the input_vector direction
	velocity += Vector2(input_vector.x * acceleration, 0).rotated(rotation)
	velocity.x = clamp(velocity.x,-max_speed, max_speed)
	velocity.y = clamp(velocity.y,-max_speed, max_speed)
	
	# Apply friction in the ship
	if input_vector.x == 0 && velocity != Vector2.ZERO:
		velocity = lerp(velocity, Vector2.ZERO, friction_weight)
		if abs(velocity.x) <= 0.1:
			velocity.x = 0
		if abs(velocity.y) <= 0.1:
			velocity.y = 0
		
	# Rotate the ship
	rotation += rotation_dir * rotation_speed * delta
	# Move the ship
	move_and_slide(velocity)

func border_teleporter():
	# Teleport the ship if it go out of the screen
	if position.x <= -110:
		position.x = 110
	elif position.x >= 110:
		position.x = -110
	elif position.y <= -110:
		position.y = 110
	elif position.y >= 110:
		position.y = -110

func active_particle():
	var particle = particle_prefab.instance()
	particle.position = position
	get_parent().add_child(particle)

func _on_Area2D_area_entered(area):
	# Detects if it collided with astreoids
	if area.is_in_group("asteroid"):
		emit_signal("explode")
		active_particle()
		queue_free()
		
	# Detects if it collided with enemies projectiles
	if area.is_in_group("enemy_projectile"):
		emit_signal("explode")
		active_particle()
		area.queue_free()
		queue_free()
	
	# Detects if it collided with the bullet package and decrease fire_rate
	if area.is_in_group("Bullet_package"):
		fire_rate -= 0.2
		if fire_rate <= 0.2:
			fire_rate = 0.2
		area.queue_free()
	
	# Detects if it collided with the life package and give life
	if area.is_in_group("Life_package"):
		emit_signal("restore_life")
		area.queue_free()
	


func _on_Timer_timeout():
	$Area2D/CollisionShape2D.disabled = false
	$CollisionShape2D.disabled = false
	can_fire = true
