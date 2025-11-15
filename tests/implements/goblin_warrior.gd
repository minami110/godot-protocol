class_name GoblinWarrior
extends Goblin

# Goblin を継承しているため、Entity を実装（is_dead(), take_damage()）
# Movable は実装していない（move_to() を追加していない）

# [Fly] Impls
func fly() -> void:
	print("GoblinWarrior is flying!")
