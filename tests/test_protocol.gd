extends GdUnitTestSuite

@warning_ignore_start("redundant_await")

#region 基本的な実装検証

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

#endregion

#region キャッシュ動作検証

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

#endregion

#region エラーハンドリング検証

func test_null引数_implements_null_オブジェクト() -> void:
	await assert_error(
		func() -> void:
			Protocol.implements(null, Entity)
	).is_runtime_error("Assertion failed: Object to verify must not be null")


func test_null引数_implements_null_Protocol() -> void:
	await assert_error(
		func() -> void:
			Protocol.implements(Goblin.new(), null)
	).is_runtime_error("Assertion failed: Protocol to verify against must not be null")


func test_プリミティブ型_int() -> void:
	assert_bool(Protocol.implements(123, Entity)).is_false()


func test_プリミティブ型_String() -> void:
	assert_bool(Protocol.implements("string", Entity)).is_false()


func test_プリミティブ型_Array() -> void:
	assert_bool(Protocol.implements([], Entity)).is_false()


func test_プリミティブ型_Dictionary() -> void:
	assert_bool(Protocol.implements({ }, Entity)).is_false()

#endregion

#region assert_implements() 検証

func test_assert_implements_成功() -> void:
	var goblin := Goblin.new()
	# アサーションが通り、エラーが発生しない
	Protocol.assert_implements(goblin, Entity)
	pass # テストが途中で失敗しなければ成功


func test_assert_implements_失敗_Protocolを実装していない() -> void:
	var goblin := Goblin.new()
	# Goblin は Wing を実装していないため、assert() が発火
	await assert_error(
		func() -> void:
			Protocol.assert_implements(goblin, Wing)
	).is_runtime_error("Assertion failed: 'Goblin' does not implement 'Wing'")

#endregion

#region 継承関係の検証

func test_継承クラス_Protocol実装継承() -> void:
	var warrior := GoblinWarrior.new()
	# GoblinWarrior は Goblin を継承しているため、Entity を実装
	assert_bool(Protocol.implements(warrior, Entity)).is_true()
	assert_bool(Protocol.implements(warrior, Movable)).is_true()

	# 追加で Wing も実装している
	assert_bool(Protocol.implements(warrior, Wing)).is_true()


func test_継承クラス_Script直接での検証() -> void:
	# クラス直接指定でも検証可能
	assert_bool(Protocol.implements(GoblinWarrior, Entity)).is_true()


func test_継承クラスのキャッシュ一貫性() -> void:
	Protocol._verification_cache.clear()

	# GoblinWarrior クラス直接での検証
	var result1 := Protocol.implements(GoblinWarrior, Entity)
	var cache_size_after_script := Protocol._verification_cache.size()

	# GoblinWarrior インスタンスでの検証（同じキャッシュエントリを使用）
	var result2 := Protocol.implements(GoblinWarrior.new(), Entity)
	var cache_size_after_instance := Protocol._verification_cache.size()

	# 結果が同じであることを確認
	assert_bool(result1).is_equal(result2)

	# キャッシュサイズが増加していないことを確認
	assert_int(cache_size_after_script).is_equal(1)
	assert_int(cache_size_after_instance).is_equal(1)

#endregion

#region 内部機能の検証

func test_get_protocol_required_methods_キャッシュ生成() -> void:
	Protocol._protocol_method_cache.clear()

	# 初回アクセス時にキャッシュが生成される
	var methods1 := Protocol._get_protocol_required_methods(Entity)
	assert_int(Protocol._protocol_method_cache.size()).is_equal(1)

	# メソッドの内容を確認
	assert_array(methods1).is_not_empty()


func test_get_protocol_required_methods_キャッシュヒット() -> void:
	Protocol._protocol_method_cache.clear()

	# 初回アクセス
	var methods1 := Protocol._get_protocol_required_methods(Entity)
	assert_int(Protocol._protocol_method_cache.size()).is_equal(1)

	# 2回目アクセス（同じProtocol）
	var methods2 := Protocol._get_protocol_required_methods(Entity)

	# 同じ配列インスタンスが返される
	assert_object(methods1).is_equal(methods2)

	# キャッシュサイズは増加しない
	assert_int(Protocol._protocol_method_cache.size()).is_equal(1)


func test_get_class_id_String型一貫性() -> void:
	var id1 := Protocol._get_class_id("Node2D")
	var id2 := Protocol._get_class_id("Node2D")

	# 同じ入力で同じIDが返される
	assert_int(id1).is_equal(id2)

	# String のハッシュ値と一致
	assert_int(id1).is_equal(hash("Node2D"))


func test_get_class_id_Script型() -> void:
	var id := Protocol._get_class_id(Entity)

	# Script のインスタンスIDが返される
	assert_int(id).is_equal((Entity as Object).get_instance_id())


func test_get_class_id_異なる入力で異なるID() -> void:
	var id1 := Protocol._get_class_id("Node2D")
	var id2 := Protocol._get_class_id("Node")

	# 異なる入力で異なるIDが返される
	assert_int(id1).is_not_equal(id2)


func test_extract_class_name_from_metatype_正常() -> void:
	var _class_name := Protocol._extract_class_name_from_metatype(Node2D)

	# クラス名が正しく抽出される
	assert_str(_class_name).is_equal("Node2D")


func test_extract_class_name_from_metatype_複数のクラス() -> void:
	var node2d_name := Protocol._extract_class_name_from_metatype(Node2D)
	var canvas_layer_name := Protocol._extract_class_name_from_metatype(CanvasLayer)

	assert_str(node2d_name).is_equal("Node2D")
	assert_str(canvas_layer_name).is_equal("CanvasLayer")


func test_複数Protocol検証_全て実装している() -> void:
	# Goblin は Entity と Movable を両方実装
	assert_bool(Protocol.implements(Goblin, Entity)).is_true()
	assert_bool(Protocol.implements(Goblin, Movable)).is_true()


func test_複数Protocol検証_一部のみ実装() -> void:
	var Ork := preload("res://tests/implements/ork.gd")
	# Ork は Entity のみ実装
	assert_bool(Protocol.implements(Ork, Entity)).is_true()
	assert_bool(Protocol.implements(Ork, Movable)).is_false()

#endregion
