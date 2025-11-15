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


func test_キャッシュの一貫性_Script直接とInstance() -> void:
	# キャッシュをクリア
	Protocol._verification_cache.clear()

	# Script直接での検証
	var result1 := Protocol.implements(Goblin, Entity)
	var cache_size_after_script := Protocol._verification_cache.size()

	# Instanceでの検証（同じキャッシュエントリを使うはず）
	var result2 := Protocol.implements(Goblin.new(), Entity)
	var cache_size_after_instance := Protocol._verification_cache.size()

	# 検証結果が同じであることを確認
	assert_bool(result1).is_equal(result2)

	# キャッシュサイズが増加していないことを確認（同じキャッシュエントリを使用）
	assert_int(cache_size_after_script).is_equal(1)
	assert_int(cache_size_after_instance).is_equal(1)


func test_キャッシュの一貫性_異なるインスタンス() -> void:
	# キャッシュをクリア
	Protocol._verification_cache.clear()

	# 最初のインスタンスで検証
	var result1 := Protocol.implements(Goblin.new(), Entity)
	var cache_size_after_first := Protocol._verification_cache.size()

	# 2番目のインスタンスで検証（同じクラスだが異なるインスタンス）
	var result2 := Protocol.implements(Goblin.new(), Entity)
	var cache_size_after_second := Protocol._verification_cache.size()

	# 検証結果が同じであることを確認
	assert_bool(result1).is_equal(result2)

	# キャッシュサイズが増加していないことを確認（同じクラスで同じキャッシュエントリを使用）
	assert_int(cache_size_after_first).is_equal(1)
	assert_int(cache_size_after_second).is_equal(1)


func test_キャッシュの分離() -> void:
	# キャッシュをクリア
	Protocol._verification_cache.clear()

	# 異なるProtocolペアで検証
	Protocol.implements(Goblin, Entity)
	var cache_size_after_first := Protocol._verification_cache.size()
	assert_int(cache_size_after_first).is_equal(1)

	Protocol.implements(Goblin, Movable)
	var cache_size_after_second := Protocol._verification_cache.size()
	assert_int(cache_size_after_second).is_equal(2)

	# 匿名クラスでも追加
	var Ork := preload("res://tests/implements/ork.gd")
	Protocol.implements(Ork, Entity)
	var cache_size_after_third := Protocol._verification_cache.size()
	assert_int(cache_size_after_third).is_equal(3)


func test_組み込みクラスのキャッシュ() -> void:
	# キャッシュをクリア
	Protocol._verification_cache.clear()

	# Script直接での検証
	var result1 := Protocol.implements(Node2D, Visible)
	var cache_size_after_script := Protocol._verification_cache.size()

	# Instanceでの検証
	var result2 := Protocol.implements(auto_free(Node2D.new()), Visible)
	var cache_size_after_instance := Protocol._verification_cache.size()

	# 検証結果が同じであることを確認
	assert_bool(result1).is_equal(result2)

	# キャッシュサイズが増加していないことを確認
	assert_int(cache_size_after_script).is_equal(1)
	assert_int(cache_size_after_instance).is_equal(1)
