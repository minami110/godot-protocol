class_name Goblin

# [Entity] Impls
func is_dead() -> bool:
	return false


# [Entity] Impls
func take_damage(amount: int) -> void:
	print("MockEnemyA took %d damage" % amount)


# [Movable] Impls
func move_to(new_position: Vector2) -> void:
	print("MockEnemyA moving to %s" % str(new_position))


# [Entity] Impls
func stop() -> void:
	print("MockEnemyA stopped")


class GoblinKing:
	# [Entity] Impls
	func is_dead() -> bool:
		return false


	# [Entity] Impls
	func take_damage(amount: int) -> void:
		print("GoblinKing took %d damage" % amount)
