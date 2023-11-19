extends Node2D

@onready var tilemap_rect = get_parent().get_used_rect()
@onready var tilemap_cell_size = get_parent().tile_set.tile_size
@onready var color = Color(0.0, 1.0, 0.0)

@export var enabled = true

func _ready():
	if enabled:
		set_process(true)
	else:
		set_process(false)

func _process(_delta):
	queue_redraw()

func _draw():
	if enabled:
		tilemap_rect = get_parent().get_used_rect()
		tilemap_cell_size = get_parent().tile_set.tile_size
		for y in range(0, tilemap_rect.size.y):
			draw_line(
				Vector2(0, y * tilemap_cell_size.y), 
				Vector2(tilemap_rect.size.x * tilemap_cell_size.x, y * tilemap_cell_size.y), 
				color
				)
		for x in range(0, tilemap_rect.size.x):
			draw_line(
				Vector2(x * tilemap_cell_size.x, 0), 
				Vector2(x * tilemap_cell_size.x, tilemap_rect.size.y * tilemap_cell_size.y), 
				color
				)
	else:
		pass
