extends Area2D

const velocity: float = 400

var player: int

func _physics_process(delta: float) -> void:
	position += (Vector2.RIGHT * velocity * delta).rotated(global_rotation)
	for snake: Player in Game.snakes:
		snake.handle_tail_collision(global_position, $CollisionShape2D.shape.radius)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('snakes'):
		pass ## todo incapacitate
	if body.is_in_group('enemies'):
		body.queue_free()
		
