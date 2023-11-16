extends GPUParticles2D

func _ready():
	Audio.get_node("explode").play()

func _on_timer_timeout():
	queue_free()
