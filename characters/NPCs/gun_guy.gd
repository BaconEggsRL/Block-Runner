extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var player: CharacterBody2D = get_tree().get_current_scene().get_node("player")
	
func _process(_delta):
	if player.position.x > self.position.x:
		anim.play("right")
	else:
		anim.play("left")
