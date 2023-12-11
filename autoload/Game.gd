extends Node

# keys
var keys_unlocked = [false]
signal key_signal

# Node Paths
const SAVE_PATH: String = "user://savegame.bin"
var START_LEVEL_PATH: String = "res://levels/Level_1.tscn"

# Preload Nodes
@onready var bg_music: AudioStreamPlayer = Audio.get_node("bg_music")
@onready var nocturne: AudioStreamPlayer = Audio.get_node("nocturne")

# Background Music / Nocturne
const DEFAULT_BG_MUSIC_VOLUME: int = -15
var saw_nocturne: bool = false
var music_missing: bool = false
var tweening = false

# Dialogue
# NATHAN_MAD_COUNT needs to be divisible by 3 for dialogue.
var NATHAN_MAD_COUNT: int = 12
var talked_to_nathan: bool = false
var gun_guy_count: int = 0

# Gravity
var DEFAULT_GRAVITY: int = 980
var DEFAULT_CRATE_GRAVITY: int = sign(DEFAULT_GRAVITY) * 500
var gravity := DEFAULT_GRAVITY
var crate_gravity := DEFAULT_CRATE_GRAVITY

# Game State Variables
var death_counter: int = 0
var has_gun: bool = false
var beat_the_game: bool = false

# Signals
signal has_gun_signal
signal gravity_changed



func _ready():
	loadGame()
	saveGame()
	assert(Game.NATHAN_MAD_COUNT % 3 == 0, "NATHAN_MAD_COUNT needs to be divisible by 3 for dialogue.")
	Game.bg_music.volume_db = Game.DEFAULT_BG_MUSIC_VOLUME


func _process(_delta):
	# restart
	if Input.is_action_just_pressed("restart"):
		if get_tree().current_scene.name == "YouWin":
			Game.resetGame()
		else:
			Game.resetLevel()


func startGame():
	# Game.DEFAULT_CRATE_GRAVITY = 2
	# Game.crate_gravity = DEFAULT_CRATE_GRAVITY
	# START_LEVEL_PATH = "res://levels/Level_5.tscn"
	
	# Game.has_gun = true
	# has_gun_signal.emit()
	get_tree().change_scene_to_file(START_LEVEL_PATH)


func change_gravity(new_gravity):
	# update game vars
	Game.gravity = new_gravity
	Game.crate_gravity = sign(new_gravity) * 500
	# emit signal
	Game.gravity_changed.emit()


func _on_music_tween_completed():
	print("end tween")
	
	# stop the music -- otherwise it continues to run at silent volume
	Game.bg_music.stop()
	Game.bg_music.volume_db = Game.DEFAULT_BG_MUSIC_VOLUME # reset volume
	
	# check if restarted during tween
	if !Game.music_missing:
		Game.nocturne.play()
	
	# no longer tweening, reset logic
	Game.tweening = false


func tween_music(tween_time: float):
	if !Game.nocturne.playing and !Game.tweening:
		print("start tween")
		var tween = create_tween()
		tween.tween_property(bg_music, "volume_db", -80, tween_time)
		tween.tween_callback(_on_music_tween_completed)
		# tweening only true once callback created
		Game.tweening = true
		# value to reset if restart during tween
		Game.music_missing = false


func get_rand() -> float:
	var rng = RandomNumberGenerator.new()
	var num: float = rng.randf()
	return num


func keyUnlock(key_unlock_number):
	Audio.get_node("key").play()
	# door remove code
	if key_unlock_number > keys_unlocked.size():
		print("key value is larger than array size")
	match key_unlock_number:
		-1:
			print("key value is -1")
		0:
			print("unlock key 0")
			keys_unlocked[0] = true
			key_signal.emit(0)
	
	
	
func nextLevel(door_level_number, door_crate_gravity):
	# reset variables
	Game.gravity = DEFAULT_GRAVITY
	if door_crate_gravity == -1:
		Game.DEFAULT_CRATE_GRAVITY = 500
	else:
		Game.DEFAULT_CRATE_GRAVITY = door_crate_gravity
	Game.crate_gravity = Game.DEFAULT_CRATE_GRAVITY
	
	# get path to next level
	var s = get_tree().current_scene.scene_file_path
	s = s.replace(".tscn", "")
	var next_level_int = door_level_number
	var next_level = "res://levels//Level_" + str(next_level_int) + ".tscn"
	
	# play door sound
	Audio.get_node("door").play()
	# go to next level
	if ResourceLoader.exists(next_level):
		get_tree().change_scene_to_file(next_level)
	else:
		# print("Scene does not exist")
		# No more levels, you win!
		Audio.get_node("win").play()
		get_tree().change_scene_to_file("res://scenes/YouWin.tscn")


func resetLevel():
	Game.gravity = DEFAULT_GRAVITY
	Game.crate_gravity = DEFAULT_CRATE_GRAVITY
	if nocturne.playing:
		nocturne.stop()
		if Game.saw_nocturne:
			music_missing = false
			bg_music.volume_db = DEFAULT_BG_MUSIC_VOLUME
			bg_music.play()
		else:
			music_missing = true
	if tweening:
		music_missing = true
	get_tree().reload_current_scene()


func resetGame():  # beat the game
	Game.beat_the_game = true
	Game.gravity = DEFAULT_GRAVITY
	Game.crate_gravity = DEFAULT_CRATE_GRAVITY
	# Game.has_gun = DEFAULT_HAS_GUN
	Game.death_counter = 0
	saveGame()
	get_tree().change_scene_to_file(START_LEVEL_PATH)


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
				# Game.has_gun = current_line["has_gun"]
				Game.talked_to_nathan = current_line["talked_to_nathan"]
				Game.beat_the_game = current_line["beat_the_game"]
				Game.gun_guy_count = current_line["gun_guy_count"]
