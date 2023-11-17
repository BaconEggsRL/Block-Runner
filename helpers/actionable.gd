extends Area2D


@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@onready var args: Dictionary = {"resource" = dialogue_resource, "start" = dialogue_start}

func action(param_args: Dictionary = args) -> CanvasLayer:
	if param_args.has("resource"):
		args["resource"] = param_args["resource"]
	if param_args.has("start"):
		args["start"] = param_args["start"]
	
	var balloon: CanvasLayer = DialogueManager.show_dialogue_balloon(args["resource"], args["start"])
	balloon.add_to_group("dialogue")
	return balloon
