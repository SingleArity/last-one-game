class_name Bullet
extends Area2D

var velocity: float = 1500

var player: int

var is_bomb = false

func scale_up(val: float):
	print(val)
	print($CollisionShape2D.shape.radius)
	print($CollisionShape2D.shape.radius * val)
	$Sprite2D.scale *= val
	$CollisionShape2D.shape.radius *= val

func _physics_process(delta: float) -> void:
	position += (Vector2.RIGHT * velocity * delta).rotated(global_rotation)
	for snake: Player in Game.snakes:
		snake.handle_tail_collision(global_position, $CollisionShape2D.shape.radius)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('snakes') and is_bomb:
		body.get_parent().got_exploded()
	if body.is_in_group('enemies'):
		body.on_enemy_shot(player)
		
