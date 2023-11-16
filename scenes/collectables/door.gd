extends Node2D
@onready var area = get_node("Area2D")
@onready var player = get_node("../../../player")
var collided = false

func _ready():
	area.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player" and collided == false:
		collided = true
		body._on_door_body_entered(body)
		# queue_free()
