class_name Movable
extends BaseProtocol

func move_to(new_position: Vector2) -> void:
	_call_method(&"move_to", new_position)


func stop() -> void:
	_call_method(&"stop")
