extends CharacterBody2D

class_name Player

const GRID_SIZE = 32
const DEFAULT_LENGTH = 20
const SHRINK_INTERVAL = 5
const HISTORY_BUFFER = 5

var segment_scene = preload("res://scenes/segment.tscn")
var move_vector = Vector2.RIGHT
var move_speed = 100.0

var head_grid_position: Vector2i
var position_history: Array[Vector2] = []
var segments: Array[Node2D] = []
var steps_taken = 0
var shrink_counter = 0
var is_alive = true
var player_name = ""
var snake_color = Color.WHITE

# Input actions for this snake
var input_up = ""
var input_down = ""
var input_left = ""
var input_right = ""

@onready var segment_container := $SegmentContainer

# Reference to the game manager (for collision checking)
var game_manager = null

func initialize(name: String, start_pos: Vector2i, color: Color, controls: Dictionary, manager = null):
	player_name = name
	head_grid_position = start_pos
	snake_color = color
	game_manager = manager
	
	# Set up controls
	input_up = controls.get("up", "")
	input_down = controls.get("down", "")
	input_left = controls.get("left", "")
	input_right = controls.get("right", "")
	
	# Create initial segments
	for i in range(DEFAULT_LENGTH):
		var seg = segment_scene.instantiate()
		seg.modulate = color
		segment_container.add_child(seg)
		segments.append(seg)

func handle_input():
	if not is_alive:
		return
	move_vector = Vector2(Input.get_axis(input_left,input_right),Input.get_axis(input_up,input_down))

func _physics_process(delta: float) -> void:
	velocity = move_vector * move_speed
	move_and_slide()


func chop_tail_at_collision(collision_index: int):
	#print(player_name, " - Chopping tail at collision index: ", collision_index)
	
	# Calculate how many segments to keep
	var segments_to_keep = collision_index - 1
	segments_to_keep = max(0, segments_to_keep)
	
	# Remove excess segments from the scene
	var segments_to_remove = segments.size() - segments_to_keep
	for i in range(segments_to_remove):
		if segments.size() > 0:
			var segment_to_remove = segments.pop_back()
			segment_to_remove.queue_free()
	
	# Trim position history to match
	if position_history.size() > segments_to_keep + 1:
		position_history.resize(segments_to_keep + 1)
	
	#print(player_name, " - Snake length after chopping: ", segments.size())

func shrink_tail():
	if segments.size() > 0:
		#print(player_name, " - Shrinking tail. Current length: ", segments.size())
		var segment_to_remove = segments.pop_back()
		segment_to_remove.queue_free()
		
		# Also trim position history to match
		if position_history.size() > segments.size() + 1:
			position_history.resize(segments.size() + 1)
		
		#print(player_name, " - New length after shrinking: ", segments.size())

func check_death():
	if segments.size() == 0:
		#print(player_name, " - DIED - Snake has no tail left!")
		is_alive = false
		#head.modulate = Color.GRAY  # Gray out dead snake

#func get_current_position() -> Vector2:
	#return head.position

func get_position_history() -> Array[Vector2]:
	return position_history
