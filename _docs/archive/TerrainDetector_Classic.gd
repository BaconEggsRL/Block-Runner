class_name TerrainDetector_Classic extends Area2D

signal terrain_entered

enum TerrainType {
	NONE = 0,
	REVERSE = 1,
	FORWARD = 2,
	SPIKE = 3
}

var previous_terrain: int = 0
var current_terrain: int = 0
var current_tilemap: TileMap

func _process_tilemap_collision(body: Node2D, body_rid: RID) -> void:
	current_tilemap = body
	var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
	var tile_data = current_tilemap.get_cell_tile_data(0, collided_tile_coords)
	if tile_data:
		var custom_data = tile_data.get_custom_data_by_layer_id(0)
		emit_signal("terrain_entered", custom_data)

# add tilemap to overlapping tiles list
func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMap:
		_process_tilemap_collision(body, body_rid)
