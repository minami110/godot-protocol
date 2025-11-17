# godot-protocol
[![Godot 4.5](https://img.shields.io/badge/Godot-4.5-478cbf?logo=godot-engine&logoColor=white)](https://godotengine.org)
[![gdunit4-tests](https://github.com/minami110/godot-protocol/actions/workflows/gdunit4-tests.yml/badge.svg)](https://github.com/minami110/godot-protocol/actions/workflows/gdunit4-tests.yml)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/minami110/godot-protocol)

GDScript で Protocol（インターフェース）パターンを実現する Godot Engine 4.5 アドオンです。
複数の Interface の実装のようなパターンを表現することができます.

## 使用パターン

### パターン A: シンプルな Protocol 宣言

`@abstract` を使った抽象クラスとして Protocol を定義します。
既存のクラスや組み込みクラスでも検証が可能です。

```gdscript
# tests/protocols/visible.gd
@abstract
class_name Visible

@abstract
func show() -> void

@abstract
func hide() -> void
```

**メリット:**
- 記述がシンプル
- Node2D など既存クラスでも検証可能

**デメリット:**
- 型安全性が低い
- IDE の補完が効きにくい

### パターン B: BaseProtocol 継承パターン

`BaseProtocol` を継承して、型安全なラッパーを実装します。Protocol であると同時に, Proxy として動作します.
ターゲットの参照は `WeakRef` で管理され、安全にアクセスできます。

```gdscript
# tests/protocols/entity.gd
class_name Entity
extends BaseProtocol

var health: int:
	get:
		return _get_property(&"health")
	set(value):
		_set_property(&"health", value)

func is_dead() -> bool:
	return _call_method(&"is_dead")

func take_damage(amount: int) -> void:
	_call_method(&"take_damage", amount)
```

**メリット:**
- 型安全で IDE の補完が効く
- `ProtocolNodeFinder` で Nodeツリー内を検索できる
- ターゲットへの安全なアクセス

**デメリット:**
- 定義がやや煩雑

## 主要 API

### Protocol.implements(obj, protocol) -> bool

対象がプロトコルを実装しているか検証します。

```gdscript
# シンプルな Protocol での使用
if Protocol.implements(node, Visible):
	var visible: Visible = Visible.new(node)
	visible.show()

# BaseProtocol ラッパーでの使用
if Protocol.implements(target, Entity):
	var entity: Entity = Entity.new(target)
	entity.take_damage(10)
```

**サポートする入力タイプ:**
- ユーザー定義クラスのインスタンス：`Goblin.new()`
- ユーザー定義クラス直接：`Goblin`
- 組み込みクラスのインスタンス：`Node2D.new()`
- 組み込みクラスのメタタイプ：`Node2D`

## ProtocolNodeFinder

Nodeツリー内でプロトコルを実装したノードを検索します。
**BaseProtocol パターンで定義された Protocol のみ使用可能です。**

### find_first_protocol_in_children(node, protocol, recursive)
子ノードからプロトコルを実装したノードを検索します。

```gdscript
# 直接の子ノードから検索
var visible: Visible = ProtocolNodeFinder.find_first_protocol_in_children(node, Visible, false)

# 子孫ノードから再帰的に検索
var visible: Visible = ProtocolNodeFinder.find_first_protocol_in_children(node, Visible, true)
```

### find_first_protocol_in_parent(node, protocol, recursive)
親ノードからプロトコルを実装したノードを検索します。

```gdscript
# 直接の親ノードから検索
var entity: Entity = ProtocolNodeFinder.find_first_protocol_in_parent(node, Entity, false)

# 親ノードから再帰的に検索（ルートまで）
var entity: Entity = ProtocolNodeFinder.find_first_protocol_in_parent(node, Entity, true)
```

### find_first_protocol_in_sibling(node, protocol)
兄弟ノード（同じ親を持つ子ノード）からプロトコルを実装したノードを検索します。

```gdscript
var entity: Entity = ProtocolNodeFinder.find_first_protocol_in_sibling(node, Entity)
```

**メリット:**
- Nodeツリー内の構造を活かしたプロトコル検索
- 型安全なラッパーを返す
