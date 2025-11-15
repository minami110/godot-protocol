extends GdUnitTestSuite

func test_2つのProtocolを実装している() -> void:
	var enemy: = Goblin.new()
	assert_bool(Protocol.implements(enemy, Entity)).is_true()
	assert_bool(Protocol.implements(enemy, Movable)).is_true()


func test_組み込み関数() -> void:
	var node_2d: Node2D = auto_free(Node2D.new())
	var canvas_layer: CanvasLayer = auto_free(CanvasLayer.new())
	var node: Node = auto_free(Node.new())

	assert_bool(Protocol.implements(node_2d, Visible)).is_true()
	assert_bool(Protocol.implements(canvas_layer, Visible)).is_true()
	assert_bool(Protocol.implements(node, Visible)).is_false()
