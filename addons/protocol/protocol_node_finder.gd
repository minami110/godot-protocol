@abstract
class_name ProtocolNodeFinder
extends Object

#region Public Methods

##
static func find_first_protocol_in_children(node: Node, protocol: Script, recursive: bool = false) -> Node:
	for child_node in node.get_children():
		if Protocol.implements(child_node, protocol):
			return child_node

		if recursive:
			var found_node: Node = find_first_protocol_in_children(child_node, protocol, true)
			if found_node != null:
				return found_node

	return null


##
static func find_first_protocol_in_ancestors(node: Node, protocol: Script) -> Node:
	var current_node: Node = node.get_parent()

	while current_node != null:
		if Protocol.implements(current_node, protocol):
			return current_node

		current_node = current_node.get_parent()

	return null

#endregion
