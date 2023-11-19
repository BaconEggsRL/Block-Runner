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
	var type_dict = {
		TerrainType.NONE: false,
		TerrainType.REVERSE: false,
		TerrainType.FORWARD: false,
		TerrainType.SPIKE: false,
	}
	
	for tile in overlapping_tiles:
		var type: int = tile["type"]
		types.append(type)
		# set colliding with tile type to true
		if type_dict.has(type):
			type_dict[type] = true
	
	# print(get_parent(), types)
	# print(get_parent(), type_dict)
	if !types.is_empty():  # is colliding with at least 1 tile
		if type_dict[TerrainType.SPIKE] == true:
			current_tile = TerrainType.SPIKE
		else:
			current_tile = types[-1]
	else:
		# do something if colliding with no tiles (airborne)
		pass
	
	# print(current_tile)
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
