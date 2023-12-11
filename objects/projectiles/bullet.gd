class_name Bullet extends Node2D

const PSPEEDX := 400.0
const PSPEEDY := 250.0
const SPEED := 700.0
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

var hit = false
@onready var area = get_node("Area2D")

func _ready():
	area.body_entered.connect(_on_body_entered)

func _process(_delta):
	self.position = self.position + self.velocity * _delta
	
func _on_body_entered(body):
	# delete bullet on any hit
	# print("hit " + body.name)
	if hit == false:
		hit = true
		if body.is_in_group("destroyable"):
			body.explode()
		queue_free()
