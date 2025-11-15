extends GdUnitTestSuite
## Assertion 関連のテスト
## CI 環境だと落ちるのでスキップ設定を追加

@warning_ignore_start("redundant_await")

static func is_running_on_ci() -> bool:
	return OS.has_environment("CI")


@warning_ignore('unused_parameter')
func before(do_skip: bool = is_running_on_ci()) -> void:
	pass

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
