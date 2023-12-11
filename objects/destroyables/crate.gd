extends RigidBody2D

@export var explosion_effect: PackedScene
var exploded = false

@onready var terrain = $terrain_detector
@onready var gravity = Game.crate_gravity


func _ready():
	physics_material_override.absorbent = 1
	Game.gravity_changed.connect(_on_Game_gravity_changed)
	
func _integrate_forces(_state):
	pass
	
func _physics_process(delta):
	var velocity = get_linear_velocity()  # get velocity
	velocity.y += gravity * delta
	set_linear_velocity(velocity)  # set velocity

func explode():
	if exploded == false:
		exploded = true
		var effect_instance : GPUParticles2D = explosion_effect.instantiate()
		get_parent().add_child(effect_instance)
		effect_instance.position = position
		effect_instance.emitting = true
		queue_free()

func _on_Game_gravity_changed():
	gravity = Game.crate_gravity

func _on_terrain_detector_terrain_entered(ter: int):
	if ter == 3:  # spike
		self.explode()
