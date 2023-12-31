extends Node2D
@onready var area = get_node("Area2D")
@onready var player = get_tree().get_current_scene().get_node("player")
var collided = false
@export var door_level_number: int = -1
@export var door_crate_gravity: int = -1

func _ready():
	area.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player" and collided == false:
		collided = true
		body._on_door_body_entered(body, door_level_number, door_crate_gravity)
		# queue_free()
