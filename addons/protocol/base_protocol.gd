@abstract
class_name BaseProtocol
extends RefCounted

var _target: WeakRef


func _init(target: Variant) -> void:
	if target == null:
		push_error("BaseProtocol target cannot be null.")
		return

	if typeof(target) != TYPE_OBJECT:
		push_error("BaseProtocol target must be an Object.")
		return

	_target = weakref(target)


func _call_method(method_name: StringName, ...arg_array: Array) -> Variant:
	if _target:
		var t: Variant = _target.get_ref()
		if t:
			return t.callv(method_name, arg_array)

	return null


func _get_property(property_name: StringName) -> Variant:
	if _target:
		var t: Variant = _target.get_ref()
		if t:
			return t.get(property_name)

	return null


func _set_property(property_name: StringName, value: Variant) -> void:
	if _target:
		var t: Variant = _target.get_ref()
		if t:
			t.set(property_name, value)
