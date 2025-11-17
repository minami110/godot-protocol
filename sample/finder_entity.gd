extends Node2D

@onready var feature_entity: Node = ProtocolNodeFinder.find_first_protocol_in_children(owner, Entity)


func _ready() -> void:
	print("Finder _ready called.")
	if feature_entity:
		print("Found Entity protocol implementation: %s" % str(feature_entity))
	else:
		print("No Entity protocol implementation found in scene.")
