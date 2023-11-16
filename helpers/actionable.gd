extends Area2D


@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func action() -> CanvasLayer:
	var balloon: CanvasLayer = DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	balloon.add_to_group("dialogue")
	return balloon
