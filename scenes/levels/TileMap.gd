extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	self.tile_set.set_physics_layer_collision_mask(0,0)
