extends Control


const MAIN_SCENE = "res://data/Scenes/World.tscn"

var credits = false

onready var menu_music = preload("res://data/Resources/Sounds/asteroid_music.mp3")
# Save data 
var save_path = "user://save.dat"
var loaded_data = {
	"last_score" : 0,
	"best_score" : 0
}
#-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-#

func _ready():
	$UI_credits.visible = false
	Transition.fade_out()
	AudioServer.set_bus_mute(0,false)
	
	$AudioStreamPlayer.stream = menu_music
	$AudioStreamPlayer.play()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	load_data()
	score_board()
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"): 
		_hide_credits()

func _on_TextureButton_button_up():
	Transition.fade_in(MAIN_SCENE)

func config_sound(condition):
	if condition:
		AudioServer.set_bus_mute(0,true)
		AudioServer.set_bus_mute(2,true)
		AudioServer.set_bus_mute(1,true)
		AudioServer.set_bus_mute(2,true)
	elif !condition:
		AudioServer.set_bus_mute(0,false)
		AudioServer.set_bus_mute(1,false)
		AudioServer.set_bus_mute(2,false)

func score_board():
	get_node("UI_main_menu/Score_board").bbcode_text = "[center]BEST SCORE: %d [center]last score: %d"\
	%	[loaded_data.best_score,loaded_data.last_score]

func load_data():
	var file = File.new()
	if file.file_exists(save_path):
		var error_file = file.open(save_path,File.READ)
		if error_file == OK:
			loaded_data = file.get_var()
		file.close()

func _on_SoundButton_pressed():
	config_sound($UI_main_menu/SoundButton.pressed)


func _on_Credits_button_mouse_entered():
	# change text color of the label to red
	get_node("UI_main_menu/Credits_button/Label").add_color_override("font_color", Color(1,0,0,1))


func _on_Credits_button_mouse_exited():
	# change text color of the label to white
	get_node("UI_main_menu/Credits_button/Label").add_color_override("font_color", Color(1,1,1,1))

func _show_credits():
	credits = true
	$UI_main_menu.visible = false
	$UI_credits.visible = true

func _hide_credits():
	$Credits_player.stop()
	credits = false
	$UI_main_menu.visible = true
	$UI_credits.visible = false

func _on_Credits_button_button_down():
	get_node("UI_main_menu/Credits_button/Label").add_color_override("font_color", Color(1,1,1,1))
	_show_credits()
	
	$Credits_player.play("Credits_scroll")
	yield($Credits_player,"animation_finished")
	
	_hide_credits()
