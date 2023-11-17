extends Node

const DEFAULT_GRAVITY = 980
const DEFAULT_CRATE_GRAVITY = sign(DEFAULT_GRAVITY) * 9
const DEFAULT_HAS_GUN: bool = false
const DEFAULT_START_LEVEL_PATH: String = "res://scenes/levels/Level_1.tscn"
const DEFAULT_DEATH_COUNTER: int = 0

var gravity = DEFAULT_GRAVITY
var crate_gravity = DEFAULT_CRATE_GRAVITY
var has_gun = DEFAULT_HAS_GUN
var start_level_path = DEFAULT_START_LEVEL_PATH
var death_counter = DEFAULT_DEATH_COUNTER

signal has_gun_signal
var talked_to_nathan: bool = false
var beat_the_game: bool = false
var gun_guy_count: int = 0

func get_rand() -> float:
	var rng = RandomNumberGenerator.new()
	var num: float = rng.randf()
	return num

func _process(_delta):
	# restart
	if Input.is_action_just_pressed("restart"):
		if get_tree().current_scene.name == "YouWin":
			resetGame()
		else:
			resetLevel()

		
func nextLevel():
	# reset variables
	gravity = DEFAULT_GRAVITY
	crate_gravity = DEFAULT_CRATE_GRAVITY
	
	# get path to next level
	var s = get_tree().current_scene.scene_file_path
	s = s.replace(".tscn", "")
	var next_level_int = int(s.right(1)) + 1
	var next_level = "res://scenes//levels//Level_" + str(next_level_int) + ".tscn"
	
	# play door sound
	Audio.get_node("door").play()

	# go to next level
	if ResourceLoader.exists(next_level):
		get_tree().change_scene_to_file(next_level)
	else:
		# print("Scene does not exist")
		# No more levels, you win!
		Audio.get_node("win").play()
		get_tree().change_scene_to_file("res://scenes//levels//YouWin.tscn")
	
func resetLevel():
	gravity = DEFAULT_GRAVITY
	crate_gravity = DEFAULT_CRATE_GRAVITY
	if Audio.get_node("nocturne").playing:
		Audio.get_node("nocturne").stop()
		Audio.get_node("background_music").volume_db = -10
		Audio.get_node("background_music").play()
	get_tree().reload_current_scene()
	
func resetGame():
	beat_the_game = true
	gravity = DEFAULT_GRAVITY
	crate_gravity = DEFAULT_CRATE_GRAVITY
	has_gun = DEFAULT_HAS_GUN
	death_counter = DEFAULT_DEATH_COUNTER
	get_tree().change_scene_to_file(start_level_path)
