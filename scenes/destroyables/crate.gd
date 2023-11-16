extends RigidBody2D

@export var explosion_effect: PackedScene
var exploded = false
var crate_gravity_is_on = true
@onready var player: CharacterBody2D = get_node("../../../player")
var collision_i = 1
var max_collisions = 30
@onready var area = $terrain_detector


func still_colliding_with_player() -> bool:
	var c = self.get_colliding_bodies()
	for body in c:
		if body is CharacterBody2D:
			return true
	return false
	

func _physics_process(_delta):
#	if self.get_collision_layer_value(1):
#		if still_colliding_with_player():
#			collision_i = 1
#		else:
#			if collision_i > max_collisions:
#				self.set_collision_layer_value(1, false)
#				collision_i = 1
#				print("OFF collision")
#			else:
#				collision_i += 1
			
	var velocity = get_linear_velocity()  # get velocity
	if crate_gravity_is_on:
		velocity.y += Game.crate_gravity  # apply gravity (change this line)
	set_linear_velocity(velocity)  # set velocity
	# remove jitter
	if abs(linear_velocity.y) <= abs(Game.crate_gravity) * 1.001:
		physics_material_override.absorbent = 1
	else:
		physics_material_override.absorbent = 0
		

func explode():
	if exploded == false:
		exploded = true
		var effect_instance : GPUParticles2D = explosion_effect.instantiate()
		get_parent().add_child(effect_instance)
		effect_instance.position = position
		effect_instance.emitting = true
		queue_free()


func _on_terrain_detector_terrain_entered(ter: int):
	if ter == 3:  # spike
		self.explode()
