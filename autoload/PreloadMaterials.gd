extends CanvasLayer

var FirstParticlesMaterial = preload("res://effects/crate_explosion.tres")
# var SecondParticlesMaterial = preload("res://effects/crate_explosion.tres")

var position = Vector2(-1000, -1000)  # load the particles off screen

var materials = [
	FirstParticlesMaterial,
	# SecondParticlesMaterial,
]

var t: float = 0


func _on_timer_timeout():
	print("DONE LOADING")
	Game.startGame()
	
func _ready():

	# add all materials to scene
	for material in materials:
		var p = GPUParticles2D.new()
		t += p.lifetime * (2 - p.explosiveness)  # lifetime of particle effect, add to total timer time
		p.set_position(position)
		p.set_process_material(material)
		p.set_one_shot(true)
		p.set_emitting(true)
		self.add_child(p)
	
	# timer for all particles to stop
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = t
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
