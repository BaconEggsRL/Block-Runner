class_name GravityFlip
extends Node2D

var collected = false
@onready var area = get_node("Area2D")

func _ready():
	area.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player" and collected == false:
		collected = true
		body._on_gravity_flip_body_entered()
		queue_free()
