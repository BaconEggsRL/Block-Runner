extends RigidBody2D

@export var explosion_effect: PackedScene
var exploded = false

@onready var player: CharacterBody2D = get_node("../../../player")
@onready var terrain = $terrain_detector
@onready var gravity = Game.gravity


func _ready():
	Game.gravity_changed.connect(_on_Game_gravity_changed)
	
	
func _physics_process(delta):
	var velocity = get_linear_velocity()  # get velocity
	velocity.y += gravity * delta
	set_linear_velocity(velocity)  # set velocity
	# remove jitter
	if abs(linear_velocity.y) <= abs(gravity) * 1.001:
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


func _on_Game_gravity_changed():
	gravity = Game.gravity


func _on_terrain_detector_terrain_entered(ter: int):
	if ter == 3:  # spike
		self.explode()
