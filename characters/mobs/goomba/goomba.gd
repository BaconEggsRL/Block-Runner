extends RigidBody2D

var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.ZERO]
var direction := Vector2.ZERO
const SPEED = 12.0  # randf_range(150.0, 250.0)
var velocity := Vector2(SPEED, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	physics_material_override.absorbent = 1
	update_behavior()
	
func _physics_process(_delta):
	# Set velocity
	self.linear_velocity = direction * velocity
	# self.linear_velocity.x = move_toward(self.linear_velocity.x, (direction * velocity).x, SPEED)

func _on_behavior_timer_timeout():
	# print("timeout")
	update_behavior()

func update_behavior():
	# Set the mob's direction to a random direction (left or right)
	direction = dirs[randi() % dirs.size()]
	# Choose the velocity for the mob.
	velocity = Vector2(SPEED, 0.0)
