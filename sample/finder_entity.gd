extends Node2D

@onready var feature_entity: Entity = ProtocolNodeFinder.find_first_protocol_in_children(owner, Entity, true)


func _ready() -> void:
	print("Finder _ready called.")
	if feature_entity:
		print("Found Entity protocol implementation: %s" % str(feature_entity))
		print(feature_entity.health)
		feature_entity.take_damage(25)
		print(feature_entity.health)

	else:
		print("No Entity protocol implementation found in scene.")
