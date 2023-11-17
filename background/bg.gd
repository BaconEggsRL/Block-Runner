extends ParallaxBackground

@onready var player = get_parent().get_node("player")
@onready var layer1 := $normal_layer
@onready var layer2 := $flipped_layer

var scrolling_speed = 100

var music: AudioStreamPlayer = Audio.get_node("nocturne")
var current_time: float = 0.0
var previous_time: float = 0.0

var purple = Color(255/255.0, 44/255.0, 255/255.0, 255/255.0)
@onready var color_list := [
	Color.RED,
	purple,
]
@onready var current_color: Color = get_color(0)
@onready var target_color: Color = color_list[0]
var color_i = 0
var nocturne = false
var start_y = 700


func _ready():
	pass
	
func _process(delta):
	scroll_offset.x -= scrolling_speed * delta
	if nocturne:
		current_time = snappedf(music.get_playback_position(), 0.01)
		if is_equal_approx(current_time, 5.00):
			current_color = Color.RED
			set_color(current_color)
		if is_equal_approx(current_time, 11.20):
			current_color = purple
			set_color(current_color)
		if is_equal_approx(current_time, 18.50):
			current_color = Color.RED
			set_color(current_color)
		if is_equal_approx(current_time, 39.00):
			current_color = purple
			set_color(current_color)
		previous_time = current_time
#		elif current_time > 6:
#			if !current_color.is_equal_approx(target_color):
#				current_color = lerp(current_color, target_color, delta)
#				set_color(current_color)
#			else:
#				color_i += 1
#				if color_i > color_list.size()-1:
#					color_i = 0
#				target_color = color_list[color_i]


func _on_player_nocturne():
	nocturne = true
	
func set_color(c: Color) -> void:
	layer1.set_modulate(c)
	layer2.set_modulate(c)

func get_color(my_layer: int) -> Color:
	var c1 = layer1.get_modulate()
	var c2 = layer2.get_modulate()
	match my_layer:
		0:
			return (c1.lerp(c2, 0.5))
		1:
			return c1
		2:
			return c2
		_:
			print("invalid call to get_color")
			return (c1.lerp(c2, 0.5))
			

func get_gradient(gradient_data: Dictionary):
	var gradient := Gradient.new()
	gradient.offsets = gradient_data.keys()
	gradient.colors = gradient_data.values()
	return gradient



