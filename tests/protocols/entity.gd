class_name Entity
extends BaseProtocol

var health: int:
	get:
		return _get_property(&"health")
	set(value):
		_set_property(&"health", value)


func is_dead() -> bool:
	return _call_method(&"is_dead")


func take_damage(amount: int) -> void:
	_call_method(&"take_damage", amount)
