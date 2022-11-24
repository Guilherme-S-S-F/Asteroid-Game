extends CanvasLayer

onready var animation  = find_node("AnimationPlayer")
var scene_to_go = ""

func _ready():
	animation = find_node("AnimationPlayer")
	
func fade_in(scene):
	scene_to_go = scene
	animation.play("fade_in")
	yield($AnimationPlayer,"animation_finished")
	change_scene()

func fade_out():
	animation.play("fade_out")

func setPlaybackSpeed(speed):
	animation.playback_speed = speed

func change_scene():
	get_tree().change_scene(scene_to_go)
