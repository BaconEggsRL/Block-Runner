extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Game.has_gun:
		self.visible = true
	else:
		self.visible = false
