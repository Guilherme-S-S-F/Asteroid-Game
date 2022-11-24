extends Node2D

const MENU_SCENE = "res://data/Scenes/Menu.tscn"

# Save data 
var save_path = "user://save.dat"
var loaded_data = {
	"last_score" : 0,
	"best_score" : 0
}
#-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-#

onready var enemy_prefab = preload("res://data/Prefabs/Enemies/Enemy1.tscn")
onready var bullet_prefab = preload("res://data/Prefabs/bullet.tscn")
onready var ship_prefab = preload("res://data/Prefabs/ship.tscn")
onready var life_prefab = preload("res://data/Prefabs/Life.tscn")
onready var shoot_sound = preload("res://data/Resources/Sounds/AsteroidShoot.mp3")
onready var powerup_bullets = preload("res://data/Prefabs/PowerUps/Bullet_Packet.tscn")
onready var powerup_life = preload("res://data/Prefabs/PowerUps/Life_package.tscn")
onready var ship_holder = $Ship_holder as Node2D
onready var life_holder = $LifeHolder as Node2D

# spawn life
var life_score_count = 200
var life_score_inc = 300
# spawn package percentage
var bullet_packet_per = 0.008
var bullet_packet_score = 360

var canspawn_package = true

var ship : Ship

export (int,0,10) var max_life = 3
export (float,0,1) var fire_rate = 0.4

var lifes
var lifes_array = []

var score = 0

var time_to_spawn = 30
var timer_spawn = 0
var enemies_count = 1

var past_time : float = 0


# Asteroids
onready var asteroids_prefab  = [
preload("res://data/Prefabs/asteroids/Asteroid G1 R.tscn"),
preload("res://data/Prefabs/asteroids/Asteroid G2 R.tscn"),
preload("res://data/Prefabs/asteroids/Asteroid M1.tscn"),
preload("res://data/Prefabs/asteroids/Asteroid M2.tscn"),
preload("res://data/Prefabs/asteroids/Asteroid P1.tscn"),
preload("res://data/Prefabs/asteroids/Asteroid P2.tscn")
]

func _ready():
	load_data()
	Transition.fade_out()
	
	# hide the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	spawn_ship()
	life_starter()
	fire_rate = ship.fire_rate
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Transition.fade_in(MENU_SCENE)
	if ship != null && ship.can_fire:
		fire_rate = ship.fire_rate
		shoot(delta)
	spawn_enemy_on_timer(delta)
			
	spawn_powerUp()
		
	# Debug
	if Input.is_action_just_pressed("Debug"):
		pass

func spawn_powerUp():
	if score > bullet_packet_score and randf() < bullet_packet_per and canspawn_package:
			var pos = Vector2(rand_range(-100,100),rand_range(-100,100))
			var bullet_packet = powerup_bullets.instance()
			bullet_packet.position = pos
			canspawn_package = false
			get_node("PowerUps").add_child(bullet_packet)
	
	if score > life_score_count:
		var pos = Vector2(rand_range(-100,100),rand_range(-100,100))
		var life_package = powerup_life.instance()
		life_package.position = pos
		
		life_score_count += life_score_inc
		
		get_node("PowerUps").add_child(life_package)
			
func restore_health():
	var children_array = life_holder.get_children()
	
	for i in range(0,children_array.size()):
		children_array[i].queue_free()
	
	lifes_array.clear()
	life_starter()
# Timer to spawn enemy ship, 
func spawn_enemy_on_timer(dt):
	timer_spawn += dt
	if timer_spawn >= time_to_spawn:
		timer_spawn = 0
		for i in range(0,enemies_count):
			spawn_enemy()
		time_to_spawn += 10
		enemies_count += 1

func spawn_enemy():
	var enemy = enemy_prefab.instance()
	enemy.position = Vector2(rand_range(-100,100),rand_range(-100,100))
	enemy.rotation = rand_range(0,360)
	get_node("Enemy_holder").add_child(enemy)
	

func spawn_ship():
	canspawn_package = true
	bullet_packet_score *= 1.7
	ship = ship_prefab.instance()
	ship.position = Vector2.ZERO
	get_node("Ship_holder").add_child(ship)

	
func life_starter():
	lifes = max_life
	
	for i in range(0,lifes):
		var new_life = life_prefab.instance()
		new_life.position = Vector2(90,-90)
		new_life.position.x = new_life.position.x - 10 * i
		new_life.scale = Vector2(0.5,0.5)
				
		life_holder.add_child(new_life)
		lifes_array.append(new_life)

func remove_life():
	if lifes > 0:
		
		lifes_array[lifes-1].queue_free()
		lifes_array.remove(lifes-1)
		spawn_ship()
		lifes -= 1
	else:
		ship = null
		save_data()
		Transition.fade_in(MENU_SCENE)

func shoot(delta):
	past_time += delta
	if Input.is_action_pressed("ui_accept") && past_time >= fire_rate:
		past_time = 0
		var new_bullet = bullet_prefab.instance()
		new_bullet.position = ship.position
		new_bullet.rotation = ship.rotation
		get_node("bullet_holder").add_child(new_bullet)
		$ShipSoundPlayer.stream = shoot_sound
		$ShipSoundPlayer.play()

func spawn_asteroid(prefab):	
	var new_asteroid = prefab.instance()
	new_asteroid.position = Vector2(rand_range(-140,-100),rand_range(-140,-100))
	new_asteroid.connect("score_up",self,"score")
	get_node("asteroid_holder").add_child(new_asteroid)

func _on_Timer_timeout():
	var num = rand_range(0,5)
	
	if $asteroid_holder.get_child_count() <= 10:
		spawn_asteroid(asteroids_prefab[num])
		
	
func score(points):
	score += points
	$Score.bbcode_text = "[center]" + str(score)

func load_data():
	var file = File.new()
	if file.file_exists(save_path):
		var error_file = file.open(save_path,File.READ)
		if error_file == OK:
			loaded_data = file.get_var()
		file.close()
func save_data():
	var last_score = score
	var best_score = loaded_data.get("best_score")
	if last_score > best_score:
		best_score = last_score
	
	loaded_data.last_score = last_score
	loaded_data.best_score = best_score
	var data = loaded_data
	
	var file = File.new()
	var error_file = file.open(save_path,File.WRITE)
	if error_file == OK:
		file.store_var(data)
		file.close()

