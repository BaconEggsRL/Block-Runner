extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = get_tree().get_current_scene().get_node("player")
@onready var actionable: Area2D = $Actionable
@onready var height: int = round(self.global_position.y)
@onready var dialogue_start: String = "start"

# get NPC dialogue start
func get_dialogue_start() -> String:
	var player_height = round(player.global_position.y)
	var bodies = actionable.get_overlapping_bodies()
	
	if bodies.size() > 0:
		if bodies[0].is_in_group("player"):
			dialogue_start = "blocked_by_player"
		elif bodies[0].is_in_group("crate"):
			dialogue_start = "blocked_by_generic"
	else:
		if player_height < self.height:
			dialogue_start = "player_high"
		else:
			dialogue_start = "start"
			if Game.saw_nocturne:
				dialogue_start = "saw_nocturne"
			if Game.music_missing:
				dialogue_start = "music_missing"
	
	if Game.talked_to_nathan:
		if Game.beat_the_game:
			Game.beat_the_game = false
			Game.gun_guy_count = 0
			dialogue_start = "met_before"
	
	Game.talked_to_nathan = true
	return dialogue_start


func _process(_delta):
	if player.position.x > self.position.x:
		anim.play("right")
	else:
		anim.play("left")
