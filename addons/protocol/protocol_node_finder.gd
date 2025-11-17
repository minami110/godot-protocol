@abstract
class_name ProtocolNodeFinder
extends Object

#region Public Methods

##
static func find_first_protocol_in_children(node: Node, protocol: Script, recursive: bool = false) -> BaseProtocol:
	for child_node in node.get_children():
		if Protocol.implements(child_node, protocol):
			return protocol.new(child_node)

		if recursive:
			var found_node: BaseProtocol = find_first_protocol_in_children(child_node, protocol, true)
			if found_node != null:
				return found_node

	return null


##
static func find_first_protocol_in_parent(node: Node, protocol: Script, recursive: bool = false) -> BaseProtocol:
	var current: Node = node.get_parent()

	if recursive:
		while current != null:
			if Protocol.implements(current, protocol):
				return protocol.new(current)

			current = current.get_parent()

	else:
		if current != null and Protocol.implements(current, protocol):
			return protocol.new(current)

	return null


##
static func find_first_protocol_in_sibling(node: Node, protocol: Script) -> BaseProtocol:
	var parent_node: Node = node.get_parent()
	if parent_node == null:
		return null

	return find_first_protocol_in_children(parent_node, protocol, false)

#endregion
