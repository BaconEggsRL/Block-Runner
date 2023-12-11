extends Node2D
@onready var area = get_node("Area2D")
@onready var player = get_tree().get_current_scene().get_node("player")
var collided = false
@export var key_unlock_number = -1

func _ready():
	area.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player" and collided == false:
		collided = true
		body._on_key_body_entered(body, key_unlock_number)
		queue_free()
