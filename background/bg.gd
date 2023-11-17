extends ParallaxBackground

@onready var player = get_parent().get_node("player")
@onready var layer1 := $normal_layer
@onready var layer2 := $flipped_layer

var scrolling_speed = 100

@onready var song: AudioStreamPlayer = Audio.get_node("nocturne")
@onready var song_length = song.stream.get_length()
var current_time: float = 0.0
var nocturne = false

var near_black = Color(75/255.0, 75/255.0, 75/255.0, 155/255.0)
var purple = Color(255/255.0, 44/255.0, 255/255.0, 255/255.0)
var red = Color.RED
# song timestamp, color, interpolation mode to next color
@onready var event_list := [

	[5.00, red, 0],
	[11.20, purple, 0],
	[18.50, red, 0],
	
	[24.00, purple, 1],
	[24.20, red, 1],
	[24.40, purple, 1],
	[24.60, red, 1],
	[24.80, purple, 1],
	[25.00, red, 1],
	[25.20, purple, 1],
	[25.40, red, 1],
	
	[39.00, purple, 1],
	[62.00, red, 1],
	[70.00, Color.WHEAT, 1],
	[76.00, Color.WHITE, 1],
	
	[90.00, near_black, 0],
	[95.00, red, 0],

	[102.50, red, 0],
	[103.00, purple, 1],
	[103.20, red, 1],
	[103.40, purple, 1],
	[103.60, red, 1],
	[103.80, purple, 1],
	[104.00, red, 1],
	[104.20, purple, 1],
	[104.40, red, 1],
	
	[105.00, purple, 1],
	[105.20, red, 1],
	[105.40, purple, 1],
	[105.60, red, 1],
	[105.80, purple, 1],
	[106.00, red, 1],
	[106.20, purple, 1],
	[106.40, red, 1],
	
	[107.00, purple, 1],
	[115.00, red, 1],
	
	[120.00, Color.BLACK, 0],
	[120.00, Color.BLACK, 0]
]

# color/interpolation gradient
var color_data: Dictionary = {}
var interpolation_data: Dictionary = {}

var color_gradient: Gradient
var constant_gradient: Gradient
var interpolation_gradient: Gradient



func _ready():

	for index in range(0, event_list.size()-1):
		# get current event
		var e = event_list[index]
		# create gradient key in range 0,1 from event timestamp (in range 0,song_length)
		var key = clamp(remap(e[0], 0.0, song_length, 0, 1), 0, 1)
		
		# get color associated with that key
		var color_value = e[1]
		var interpolation_value: Color
		if e[2]: # linear
			interpolation_value = Color.WHITE
		else: # constant
			interpolation_value = Color.BLACK
			
		# add key value pair to gradient data
		color_data[key] = color_value
		interpolation_data[key] = interpolation_value
	
	# get gradient
	color_gradient = get_gradient(color_data, Gradient.GRADIENT_INTERPOLATE_LINEAR)
	interpolation_gradient = get_gradient(interpolation_data, Gradient.GRADIENT_INTERPOLATE_CONSTANT)
	constant_gradient = get_gradient(color_data, Gradient.GRADIENT_INTERPOLATE_CONSTANT)



func _process(delta):
	scroll_offset.x -= scrolling_speed * delta
	
	if nocturne:
		# get current time
		current_time = snappedf(song.get_playback_position(), 0.01)
		# print(current_time)
		# convert time to range 0,1 for gradient
		var key = clamp(remap(current_time, 0.0, song_length, 0, 1), 0, 1)
		# get color and interpolation
		var interp: Color = interpolation_gradient.sample(key)
		var current_color: Color
		if interp == Color.WHITE: # linear
			current_color = color_gradient.sample(key)
		else: # constant
			current_color = constant_gradient.sample(key)
		# set color
		if get_color(0) != current_color and current_time>=5.00:
			set_color(current_color)
			# print("set color", current_color)




func _on_player_nocturne() -> void:
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
			

func get_gradient(data: Dictionary, mode) -> Gradient:
	var g := Gradient.new()
	g.interpolation_mode = mode
	g.offsets = data.keys()
	g.colors = data.values()
	return g



