extends Node2D

@onready var feature_entity: Entity = ProtocolNodeFinder.find_first_protocol_in_children(self, Entity)
@onready var feature_movable: Movable = ProtocolNodeFinder.find_first_protocol_in_children(self, Movable)


func _ready() -> void:
	print("Sample _ready called.")
	if feature_entity:
		print("Found Entity protocol implementation: %s" % str(feature_entity))
	else:
		print("No Entity protocol implementation found in scene.")
