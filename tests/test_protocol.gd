extends GdUnitTestSuite

func test_2つのProtocolを実装している() -> void:
	var enemy: = Goblin.new()
	assert_bool(Protocol.implements(enemy, Entity)).is_true()
	assert_bool(Protocol.implements(enemy, Movable)).is_true()


func test_匿名クラス() -> void:
	var Ork := preload("res://tests/implements/ork.gd")
	var enemy := Ork.new()
	assert_bool(Protocol.implements(enemy, Entity)).is_true()
	assert_bool(Protocol.implements(enemy, Movable)).is_false()


func test_組み込みクラス() -> void:
	var node_2d: Node2D = auto_free(Node2D.new())
	var canvas_layer: CanvasLayer = auto_free(CanvasLayer.new())
	var node: Node = auto_free(Node.new())

	assert_bool(Protocol.implements(node_2d, Visible)).is_true()
	assert_bool(Protocol.implements(canvas_layer, Visible)).is_true()
	assert_bool(Protocol.implements(node, Visible)).is_false()


func test_内部クラス() -> void:
	var enemy := Goblin.GoblinKing.new()
	assert_bool(Protocol.implements(enemy, Entity)).is_true()
	assert_bool(Protocol.implements(enemy, Movable)).is_false()


func test_クラス直接() -> void:
	# 通常クラス
	assert_bool(Protocol.implements(Goblin, Entity)).is_true()
	assert_bool(Protocol.implements(Goblin, Movable)).is_true()

	# 内部クラス
	assert_bool(Protocol.implements(Goblin.GoblinKing, Entity)).is_true()
	assert_bool(Protocol.implements(Goblin.GoblinKing, Movable)).is_false()

	# 匿名クラス
	var Ork := preload("res://tests/implements/ork.gd")
	assert_bool(Protocol.implements(Ork, Entity)).is_true()
	assert_bool(Protocol.implements(Ork, Movable)).is_false()

	# 組み込み
	assert_bool(Protocol.implements(Node2D, Visible)).is_true()
	assert_bool(Protocol.implements(CanvasLayer, Visible)).is_true()
	assert_bool(Protocol.implements(Node, Visible)).is_false()


func test_Protocolの実装が足りていない() -> void:
	pass


func test_二度目のクエリではキャッシュが行われている() -> void:
	pass
