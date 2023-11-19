extends Node

const SAVE_PATH = "user://savegame.bin"

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
var saw_nocturne: bool = false
var music_missing: bool = false

const NATHAN_MAD_COUNT: int = 10

const DEFAULT_MUSIC_VOLUME: int = -15
@onready var bg_music: AudioStreamPlayer = Audio.get_node("bg_music")
@onready var nocturne: AudioStreamPlayer = Audio.get_node("nocturne")
var tweening = false
var restarted = false

signal gravity_changed


func change_gravity(new_gravity):
	# update game vars
	Game.gravity = new_gravity
	Game.crate_gravity = sign(Game.gravity) * 9
	# emit signal
	gravity_changed.emit()
	
	
func _on_music_tween_completed():
	print("end tween")
	tweening = false
	# stop the music -- otherwise it continues to run at silent volume
	bg_music.stop()
	bg_music.volume_db = -10 # reset volume
	# play nocturne
	if !restarted:
		nocturne.play()
	restarted = false
	if nocturne.playing == false:
		Game.music_missing = true
	else:
		Game.music_missing = false
	
	
	
func tween_music():
	if !nocturne.playing:
		if !tweening:
			print("start tween")
			var tween = create_tween()
			tween.tween_property(bg_music, "volume_db", -80, 3.00)
			tween.tween_callback(_on_music_tween_completed)
			tweening = true
	
func _ready():
	loadGame()
	saveGame()
	bg_music.volume_db = DEFAULT_MUSIC_VOLUME

func get_rand() -> float:
	var rng = RandomNumberGenerator.new()
	var num: float = rng.randf()
	return num

func _process(_delta):
	# restart
	if Input.is_action_just_pressed("restart"):
		if get_tree().current_scene.name == "YouWin":
			Game.resetGame()
		else:
			Game.resetLevel()

		
func nextLevel():
	# reset variables
	Game.gravity = DEFAULT_GRAVITY
	Game.crate_gravity = DEFAULT_CRATE_GRAVITY
	
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
	Game.gravity = DEFAULT_GRAVITY
	Game.crate_gravity = DEFAULT_CRATE_GRAVITY
	if nocturne.playing:
		nocturne.stop()
		if Game.saw_nocturne:
			bg_music.volume_db = DEFAULT_MUSIC_VOLUME
			bg_music.play()
		else:
			Game.music_missing = true
	restarted = true
	get_tree().reload_current_scene()
	
func resetGame():  # beat the game
	Game.beat_the_game = true
	Game.gravity = DEFAULT_GRAVITY
	Game.crate_gravity = DEFAULT_CRATE_GRAVITY
	# Game.has_gun = DEFAULT_HAS_GUN
	Game.death_counter = DEFAULT_DEATH_COUNTER
	saveGame()
	get_tree().change_scene_to_file(start_level_path)



func saveGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data: Dictionary = {
		"has_gun": Game.has_gun,
		"talked_to_nathan": Game.talked_to_nathan,
		"beat_the_game": Game.beat_the_game,
		"gun_guy_count": Game.gun_guy_count
	}
	var jstr = JSON.stringify(data)
	file.store_line(jstr)
	
func loadGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if FileAccess.file_exists(SAVE_PATH):
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line: # returns null if parsing failed
				Game.has_gun = current_line["has_gun"]
				Game.talked_to_nathan = current_line["talked_to_nathan"]
				Game.beat_the_game = current_line["beat_the_game"]
				Game.gun_guy_count = current_line["gun_guy_count"]
