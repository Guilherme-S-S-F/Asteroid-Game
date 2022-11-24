extends KinematicBody2D

onready var bullet_prefab = preload("res://data/Prefabs/Enemies/enemy_bullet.tscn")
onready var shoot_sound = preload("res://data/Resources/Sounds/AsteroidShoot.mp3")
onready var particle_prefab = preload("res://data/Prefabs/ShipParticle.tscn")

signal score_up(score)

export(float) var speed = 50.0
export(float) var offset = 100

var ship : KinematicBody2D
var dir = Vector2.ZERO

var points = 20

var see_ship = false

var timer = 0
func _ready():
	# Play the spawn effect
	$AnimationPlayer.play("Flash_enemy")
	
	connect("score_up",get_tree().get_root().find_node("World",true,false),"score")

func _physics_process(delta):
	movement(delta)
	shoot(delta)
	
func movement(dt):
	if ship != null:
		if position.distance_to(ship.position) >= offset:
			dir = position.direction_to(ship.position) * speed
			dir = move_and_slide(dir)
		look_at(ship.position)

func shoot(dt):
	timer += dt
	if timer >= 3 && see_ship:
		timer = 0
		var new_bullet = bullet_prefab.instance()
		new_bullet.position = position
		new_bullet.rotation = rotation
		get_parent().get_parent().get_node("bullet_holder").add_child(new_bullet)
		$AudioStreamPlayer.stream = shoot_sound
		$AudioStreamPlayer.play()

func _on_Vision_body_entered(body):
	if body.is_in_group("ship"):
		ship = body
		see_ship = true

func _on_Vision_body_exited(body):
	if body.is_in_group("ship"):
		ship = null
		see_ship = false

func _on_Timer_timeout():
	$Vision/CollisionShape2D.disabled = false
	$CollisionShape2D.disabled = false
	$Area2D/CollisionShape2D.disabled = false

func active_particle():
	var particle = particle_prefab.instance()
	particle.position = position
	get_parent().add_child(particle)

func _on_Area2D_area_entered(area):
	if area.is_in_group("projectile"):
		area.queue_free()
		emit_signal("score_up",points)
		active_particle()
		get_node(".").queue_free()
