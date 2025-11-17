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
static func find_first_protocol_in_ancestors(node: Node, protocol: Script) -> BaseProtocol:
	var current_node: Node = node.get_parent()

	while current_node != null:
		if Protocol.implements(current_node, protocol):
			return protocol.new(current_node)

		current_node = current_node.get_parent()

	return null

#endregion
