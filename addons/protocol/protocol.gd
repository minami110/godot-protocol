@abstract
class_name Protocol
extends Object

#region Private Static Variables

static var _protocol_method_cache: Dictionary[int, Array] = { }
static var _verification_cache: Dictionary[int, bool] = { }

#endregion

#region Public Methods

static func implements(obj: Object, protocol: Script) -> bool:
	assert(obj != null)
	assert(protocol != null)

	var obj_script: Script = obj.get_script()

	# Node クラスなど, Godot 組み込みクラスのインスタンスが渡されている場合
	if obj_script == null:
		var builtin_class_name: String = obj.get_class()
		return _verify_builtin_class(builtin_class_name, protocol)
	else:
		return _verify_user_class(obj, protocol)


static func assert_implements(obj: Object, cls: Script) -> void:
	if implements(obj, cls) == false:
		var obj_global_class_name: String = obj.get_script().get_global_name()
		if obj_global_class_name.is_empty():
			assert(false, "Object of '%s' does not implement '%s'." % [obj.get_script().resource_path, cls.get_global_name()])
		else:
			assert(false, "Object of type '%s' does not implement '%s'." % [obj_global_class_name, cls.get_global_name()])

#endregion

static func _verify_builtin_class(builtin_class_name: String, protocol: Script) -> bool:
	var required_methods: = _get_required_methods(protocol)

	for method_dict in required_methods:
		var method_name: String = method_dict.name

		# ClassDBでメソッドの存在確認
		if not ClassDB.class_has_method(builtin_class_name, method_name):
			return false

		# シグネチャ検証（ClassDB.class_get_method_list使用）
		# TODO:

	return true


static func _verify_user_class(obj: Object, protocol: Script) -> bool:
	var obj_script: Script = obj.get_script()

	# ペアの検証結果がキャッシュにあるか確認
	var cache_key := hash([obj_script.get_instance_id(), protocol.get_instance_id()])
	if _verification_cache.has(cache_key):
		return _verification_cache[cache_key]

	var required_methods: = _get_required_methods(protocol)

	for method_dict in required_methods:
		var method_name: String = method_dict.name

		# メソッドの存在チェック
		if not obj.has_method(method_name):
			_verification_cache[cache_key] = false
			return false

		# シグネチャの検証
		# if not _verify_signature(obj, method_dict):
		# 	_verification_cache[cache_key] = false
		# 	return false

	# 検証成功、結果をキャッシュ
	_verification_cache[cache_key] = true
	return true


## プロトコルの必須メソッドをキャッシュから取得または計算
## abstract メソッドのリストを返す
## 一度アクセスしたらキャッシュに保存される
static func _get_required_methods(cls: Script) -> Array[Dictionary]:
	var id := cls.get_instance_id()

	if not _protocol_method_cache.has(id):
		var method_list: Array[Dictionary] = cls.get_script_method_list()

		# @abstract メソッドを抽出 する
		# Return value:
		# https://docs.godotengine.org/ja/4.x/classes/class_object.html#class-object-method-get-method-list
		_protocol_method_cache[id] = method_list.filter(
			func(method_dict: Dictionary) -> bool:
				return method_dict.flags & METHOD_FLAG_VIRTUAL_REQUIRED != 0
		)
		_protocol_method_cache[id].make_read_only()

	return _protocol_method_cache[id]


## オブジェクトのメソッドシグネチャが期待される定義と一致するか検証
## TODO: 4.5 で abstract の場合正しく機能しない問題がある
## https://github.com/godotengine/godot/issues/110818
static func _verify_signature(obj: Object, expected_method: Dictionary) -> bool:
	var obj_script: Script = obj.get_script()
	if obj_script == null:
		return false

	var obj_methods: Array[Dictionary] = obj_script.get_script_method_list()

	# オブジェクトから対象メソッドを検索
	var actual_method: Dictionary = { }
	for method_dict in obj_methods:
		if method_dict.name == expected_method.name:
			actual_method = method_dict
			break

	if actual_method.is_empty():
		return false

	# 引数の数を比較
	var expected_args: Array = expected_method.get("args", [])
	var actual_args: Array = actual_method.get("args", [])

	if expected_args.size() != actual_args.size():
		return false

	# 各引数の型を比較
	for i in range(expected_args.size()):
		var expected_arg: Dictionary = expected_args[i]
		var actual_arg: Dictionary = actual_args[i]

		# 型が指定されている場合のみチェック
		if expected_arg.has("type") and actual_arg.has("type"):
			if expected_arg.type != actual_arg.type:
				return false

	# 返り値の型を比較
	var expected_return: Dictionary = expected_method.get("return", { })
	var actual_return: Dictionary = actual_method.get("return", { })

	if expected_return.has("type") and actual_return.has("type"):
		if expected_return.type != actual_return.type:
			return false

	return true
