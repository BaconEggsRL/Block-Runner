extends Label

func _ready():
	self.visible = false
	
func _on_tip_timer_timeout():
	self.visible = true
