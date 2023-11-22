extends Node2D

var t = 0.0
var starting_transform
var final_transform


func _ready():
	starting_transform = transform
	final_transform = transform
	
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
