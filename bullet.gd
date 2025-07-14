extends Area2D

const velocity: float = 100

func _physics_process(delta: float) -> void:
	position += (Vector2.RIGHT * velocity * delta).rotated(global_rotation)
	for snake: Player in Game.snakes:
		snake.handle_tail_collision(global_position, $CollisionShape2D.shape.radius)
