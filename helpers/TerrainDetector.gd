class_name TerrainDetector extends Area2D

signal terrain_entered
@export var detector_shape: CollisionShape2D

enum TerrainType {
	NONE = 0,
	REVERSE = 1,
	FORWARD = 2,
	SPIKE = 3
}
var overlapping_tiles: Array = []
var current_tile = -1
var previous_tile = -1

# get unique array of all tile types
func _process_tile_data() -> void:
	var types = []
	for tile in overlapping_tiles:
		var type: int = tile["type"]
		types.append(type)
	
	if !types.is_empty():
		current_tile = types[-1]
	else:
		# current_tile = 0
		pass
	
	if current_tile != previous_tile:
		emit_signal("terrain_entered", current_tile)
		previous_tile = current_tile

# get the type of a single tile
func _get_type(body: TileMap, body_rid: RID) -> int:
	var tile: TileMap = body
	var tile_coords = tile.get_coords_for_body_rid(body_rid)
	var tile_data = tile.get_cell_tile_data(0, tile_coords)
	if tile_data:
		var custom_data = tile_data.get_custom_data_by_layer_id(0)
		return custom_data
	else:
		return -1

# add tile to tile list
func _on_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		var my_tile = {"body_rid": body_rid, "body": body, "type": _get_type(body, body_rid)} 
		overlapping_tiles.append(my_tile)
		_process_tile_data()

# remove tile from tile list
func _on_body_shape_exited(body_rid, body, _body_shape_index, _local_shape_index):
	if body is TileMap:
		for tile in overlapping_tiles:
			if tile["body_rid"] == body_rid:
				var i = overlapping_tiles.find(tile)
				overlapping_tiles.remove_at(i)
		_process_tile_data()
