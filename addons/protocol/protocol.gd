@abstract
class_name Protocol
extends Object

#region Private Static Variables

static var _protocol_method_cache: Dictionary[int, Array] = { }
static var _verification_cache: Dictionary[int, bool] = { }

#endregion

#region Public Methods

## Verifies whether an object or class implements the specified protocol.
##
## This function checks if the given object/class implements all abstract methods
## required by the protocol. It supports instances, user-defined classes, built-in
## classes, and class metatypes.
##
## [param obj]: The object or class to verify. Can be:
## - An instance of a user-defined class (e.g., [code]Goblin.new()[/code])
## - A user-defined class directly (e.g., [code]Goblin[/code])
## - An instance of a built-in class (e.g., [code]Node2D.new()[/code])
## - A built-in class metatype (e.g., [code]Node2D[/code])
## - A primitive type (returns false)
##
## [param protocol]: The protocol class to verify against. Must be an abstract
## class (marked with [code]@abstract[/code]) containing abstract methods.
##
## [return]: [code]true[/code] if the object/class implements all required
## abstract methods of the protocol; [code]false[/code] otherwise.
##
## [b]Usage Examples:[/b]
## [codeblock]
## # Verify instance implementation
## var enemy := Goblin.new()
## if Protocol.implements(enemy, Entity):
##     print("Goblin implements Entity protocol")
##
## # Verify class directly
## if Protocol.implements(Goblin, Movable):
##     print("Goblin implements Movable protocol")
##
## # Verify built-in class
## if Protocol.implements(Node2D, Visible):
##     print("Node2D implements Visible protocol")
## [/codeblock]
##
## [b]Note:[/b] Results are cached for performance. Verification is done by
## checking method existence in user-defined classes and built-in classes.
static func implements(obj: Variant, protocol: Script) -> bool:
	assert(obj != null, "Object to verify must not be null")
	assert(protocol != null, "Protocol to verify against must not be null")

	# Object 以外の型が渡された場合は false を返す
	if typeof(obj) != TYPE_OBJECT:
		return false

	# ケース: Script（ユーザー定義クラス）が直接渡された場合
	# 例: Protocol.implements(Goblin, Entity)
	if obj is Script:
		return _verify_user_script(obj, protocol)

	# ケース: GDScriptNativeClass (組み込みクラスのメタタイプ) が渡された場合
	# 例: Protocol.implements(Node2D, Visible)
	# Note: (obj as Object) とキャストすることで GDScriptNativeClass の判定は行える
	if (obj as Object).is_class("GDScriptNativeClass"):
		var builtin_class_name: String = _extract_class_name_from_metatype(obj)

		if builtin_class_name.is_empty() == false:
			return _verify_builtin_class(builtin_class_name, protocol)

		push_warning("Failed to extract class name from GDScriptNativeClass: %s" % obj)
		return false

	# ケース: インスタンスが渡されている場合
	# 組み込みクラスの場合, get_script() が null を返すのでそれで分岐する
	var obj_script: Script = obj.get_script()

	# Node クラスなど, Godot 組み込みクラスのインスタンスが渡されている場合
	if obj_script == null:
		var builtin_class_name: String = obj.get_class()
		return _verify_builtin_class(builtin_class_name, protocol)

	# Goblin クラスなど, ユーザー定義クラスのインスタンスが渡されている場合
	else:
		return _verify_user_script(obj_script, protocol)


## Asserts that an object implements the specified protocol.
##
## This function verifies that the given object implements all required abstract
## methods of the protocol. If the object does not implement the protocol, an
## assertion error is raised with a descriptive message.
##
## [param obj]: The object instance to verify.
##
## [param cls]: The protocol class to verify against. Must be an abstract class
## (marked with [code]@abstract[/code]) containing abstract methods.
##
## [b]Behavior:[/b]
## - If the object implements the protocol: does nothing and returns normally.
## - If the object does not implement the protocol: triggers an assertion error
##   with the message [code]"'ClassName' does not implement 'ProtocolName'"[/code].
##
## [b]Usage Examples:[/b]
## [codeblock]
## # Success case - Goblin implements Entity
## var goblin := Goblin.new()
## Protocol.assert_implements(goblin, Entity)  # No error
##
## # Failure case - Goblin does not implement Wing
## var goblin := Goblin.new()
## Protocol.assert_implements(goblin, Wing)
## # AssertionError: 'Goblin' does not implement 'Wing'
## [/codeblock]
##
## [b]Note:[/b] This is useful in debug mode for enforcing protocol contracts
## at runtime. Use [method implements] for conditional checks without errors.
static func assert_implements(obj: Object, protocol: Script) -> void:
	if OS.is_debug_build() == false:
		return

	if implements(obj, protocol):
		return

	var obj_global_class_name: String = obj.get_script().get_global_name()
	if obj_global_class_name.is_empty():
		assert(false, "'%s' does not implement '%s'" % [obj.get_script().resource_path, protocol.get_global_name()])
	else:
		assert(false, "'%s' does not implement '%s'" % [obj_global_class_name, protocol.get_global_name()])

#endregion

## GDScriptNativeClass からクラス名を抽出, 現状 API が公開されていないため, やばい方法で行う
## Issue: https://github.com/godotengine/godot-proposals/issues/9160
static func _extract_class_name_from_metatype(metatype: Variant) -> String:
	if metatype is Object:
		var instance: Object = metatype.new()
		if instance is Object:
			var instance_class_name: String = instance.get_class()
			instance.free()
			return instance_class_name

	return ""


## ビルトインクラスのプロトコル実装を検証, この場合 String でクラス名を受け取るので ClassDB で解決を行う
static func _verify_builtin_class(builtin_class_name: String, protocol: Script) -> bool:
	# ペアの検証結果がキャッシュにあるか確認
	var pair_hash := hash([_get_class_id(builtin_class_name), _get_class_id(protocol)])

	if _verification_cache.has(pair_hash):
		return _verification_cache[pair_hash]

	var required_methods: = _get_protocol_required_methods(protocol)

	for method_dict in required_methods:
		var method_name: String = method_dict.name

		# ClassDBでメソッドの存在確認
		if not ClassDB.class_has_method(builtin_class_name, method_name):
			_verification_cache[pair_hash] = false
			return false

		# シグネチャ検証（ClassDB.class_get_method_list使用）
		# TODO:

	_verification_cache[pair_hash] = true
	return true


## ユーザー定義クラスのプロトコル実装を検証
static func _verify_user_script(script: Script, protocol: Script) -> bool:
	# ペアの検証結果がキャッシュにあるか確認
	var pair_hash := hash([_get_class_id(script), _get_class_id(protocol)])

	if _verification_cache.has(pair_hash):
		return _verification_cache[pair_hash]

	var required_methods: = _get_protocol_required_methods(protocol)
	var script_methods: Array[Dictionary] = script.get_script_method_list()

	# 必須メソッドがすべて存在するか確認
	for required_method in required_methods:
		var method_name: String = required_method.name

		if script_methods.any(
			func(m: Dictionary) -> bool:
				# TODO: シグネチャ検証を追加
				return m.name == method_name
		):
			continue

		_verification_cache[pair_hash] = false
		return false

	# 検証成功、結果をキャッシュ
	_verification_cache[pair_hash] = true
	return true


## キャッシュ管理用の一意なIDを取得, 参照カウンタを増やさないように文字列及び InstanceID を使用する
static func _get_class_id(obj: Variant) -> int:
	# ビルトインクラスの場合は String で管理する
	if typeof(obj) == TYPE_STRING:
		return hash(obj)

	# Goblin のような Script クラスが渡された場合の対応
	elif obj is Script:
		return obj.get_instance_id()

	# その他
	return hash(obj)


## プロトコルの必須メソッドをキャッシュから取得または計算
## abstract メソッドのリストを返す
## 一度アクセスしたらキャッシュに保存される
static func _get_protocol_required_methods(protocol: Script) -> Array[Dictionary]:
	var id := _get_class_id(protocol)

	if not _protocol_method_cache.has(id):
		var method_list: Array[Dictionary] = protocol.get_script_method_list()
		# @abstract メソッドを抽出 する
		# Return value:
		# https://docs.godotengine.org/ja/4.x/classes/class_object.html#class-object-method-get-method-list
		_protocol_method_cache[id] = method_list.filter(
			func(method_dict: Dictionary) -> bool:
				return method_dict.flags & METHOD_FLAG_VIRTUAL_REQUIRED != 0
		)
		_protocol_method_cache[id].make_read_only()

	return _protocol_method_cache[id]

# ## オブジェクトのメソッドシグネチャが期待される定義と一致するか検証
# ## TODO: 4.5 で abstract の場合正しく機能しない問題がある
# ## https://github.com/godotengine/godot/issues/110818
# static func _verify_signature(obj: Object, expected_method: Dictionary) -> bool:
# 	var obj_script: Script = obj.get_script()
# 	if obj_script == null:
# 		return false

# 	var obj_methods: Array[Dictionary] = obj_script.get_script_method_list()

# 	# オブジェクトから対象メソッドを検索
# 	var actual_method: Dictionary = { }
# 	for method_dict in obj_methods:
# 		if method_dict.name == expected_method.name:
# 			actual_method = method_dict
# 			break

# 	if actual_method.is_empty():
# 		return false

# 	# 引数の数を比較
# 	var expected_args: Array = expected_method.get("args", [])
# 	var actual_args: Array = actual_method.get("args", [])

# 	if expected_args.size() != actual_args.size():
# 		return false

# 	# 各引数の型を比較
# 	for i in range(expected_args.size()):
# 		var expected_arg: Dictionary = expected_args[i]
# 		var actual_arg: Dictionary = actual_args[i]

# 		# 型が指定されている場合のみチェック
# 		if expected_arg.has("type") and actual_arg.has("type"):
# 			if expected_arg.type != actual_arg.type:
# 				return false

# 	# 返り値の型を比較
# 	var expected_return: Dictionary = expected_method.get("return", { })
# 	var actual_return: Dictionary = actual_method.get("return", { })

# 	if expected_return.has("type") and actual_return.has("type"):
# 		if expected_return.type != actual_return.type:
# 			return false

# 	return true
