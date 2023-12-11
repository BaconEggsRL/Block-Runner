extends Node2D

var t = 0.0
var starting_transform
var final_transform


func _on_key_signal(key : int):
	if Game.keys_unlocked[key]:
		var wall_name = "key_wall_" + str(key)
		if has_node(wall_name):
			get_node(wall_name).queue_free()
	
func _ready():
	Game.key_signal.connect(_on_key_signal)
	starting_transform = transform
	final_transform = transform
	
	# reset keys after scene reloads
	for i in range(0, Game.keys_unlocked.size()):
		if Game.keys_unlocked[i]:
			# don't use keyUnlock because that sets the value and plays the sound
			# only use keyUnlock when you obtain the key. Otherwise use _on_key_signal to reset wall.
			Game.key_signal.emit(0)


func _physics_process(delta):
	if final_transform != transform:
		t += delta/100
		transform = transform.interpolate_with(final_transform, t)

func _on_rotate_left_body_entered(_body):
	final_transform = transform.rotated(-PI/2)
	t = 0.0

func _on_rotate_right_body_entered(_body):
	final_transform = transform.rotated(PI/2)
	t = 0.0
