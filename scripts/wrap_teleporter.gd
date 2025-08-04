extends Node

@export var subject: Node2D
@export var to_teleport: Array[Node2D] = []

func _ready():
	if subject == null:
		subject = get_parent()
	assert(subject is Node2D, "WrapTeleporter needs a 'subject' param that is a Node2D")

func _physics_process(_d):
	var bounds := get_viewport().get_visible_rect().size
	var pos := subject.global_position
	var translation = Vector2.ZERO
	if pos.x < 0:
		translation.x = bounds.x
	elif pos.x > bounds.x:
		translation.x = -bounds.x
	if pos.y < 0:
		translation.y = bounds.y
	elif pos.y > bounds.y:
		translation.y = -bounds.y
	teleport(translation)
		
func teleport(translation: Vector2):
	for it in to_teleport:
		if it is Line2D:
			for i in len(it.points):
				it.points[i] += translation
			continue
		it.global_position += translation
		if it is PhysicsBody2D:
			it.reset_physics_interpolation()
