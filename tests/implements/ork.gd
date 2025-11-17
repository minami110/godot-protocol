var _health: int = 100

# [Entity] Impls
var health: int:
	get:
		return _health
	set(value):
		_health = value


# [Entity] Impls
func is_dead() -> bool:
	return false


# [Entity] Impls
func take_damage(amount: int) -> void:
	print("MockEnemyA took %d damage" % amount)
