## This thing duplicates itself in a grid to make wrapping happen.
## Each piece of a scene that should wrap, needs this script.
extends Node2D

static var places: Array[Vector2i]= [
	Vector2i(-1, -1),
	Vector2i(-1,  0),
	Vector2i(-1,  1),
	Vector2i( 0, -1),
	Vector2i( 0,  1),
	Vector2i( 1, -1),
	Vector2i( 1,  0),
	Vector2i( 1,  1),
]

# 3x3 grid of clones handles every edge case without excess teleporting
var clones: Array[Node2D] = []

func _ready():
	for place in places:
		var clone := duplicate(DuplicateFlags.DUPLICATE_SIGNALS | DuplicateFlags.DUPLICATE_GROUPS | DuplicateFlags.DUPLICATE_USE_INSTANTIATION)
		add_sibling.call_deferred(clone)
		clones.append(clone)
	wrap_it()

func _process(_d):
	wrap_it()

## this needs to copy all dynamic properties from the copied node to its clones.
func wrap_it():
	var primary = get_parent()
	var playarea: Vector2i = get_viewport().get_visible_rect().size
	for i in len(clones):
		var clone = clones[i]
		var place = places[i]
		clone.global_position = global_position + Vector2(playarea * place)
		clone.global_rotation = global_rotation
		clone.global_scale = global_scale
	
		if is_class('Line2D'):
			# shouldn't need to change the points because we change the position of the line2d
			(clone as Line2D).points = self.points
		elif is_class('AnimatedSprite2D'):
			clone.animation = self.animation
			clone.frame = self.frame
		elif is_class('CollisionShape2D'):
			clone.disabled = self.disabled
		elif is_class('GPUParticles2D'):
			clone.emitting = self.emitting
