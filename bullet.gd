extends Area2D

@export var velocity: float = 1000.0

# it always goes right locally, rotate bullet to change the direction
func _process(delta: float) -> void:
	position += Vector2.RIGHT * velocity * delta
