extends Node

var length = 100;
var segment_length = 1;

var move_vector := Vector2.RIGHT
var move_speed = 100.0
var last_pos := Vector2.ZERO

var is_alive = true

var input_up
var input_down
var input_left
var input_right

func _ready():
	var initial_segments = length / segment_length
	var point = Vector2.LEFT * length
	for i in range(initial_segments):
		point.x += segment_length
		$Segments.add_point(point)

func _physics_process(delta: float) -> void:
	$Head.velocity = move_vector * move_speed
	$Head.move_and_slide()
	
	var head_pos = $Head.global_position
	
	var head_diff := get_head_diff()
	while head_diff.length() >= segment_length:
		var head_segment = $Segments.points[$Segments.get_point_count() - 1]
		var new_pos = head_segment + head_diff.limit_length(segment_length)
		$Segments.add_point(new_pos)
		head_diff = get_head_diff()
	
	var max_segments = length / segment_length;
	while $Segments.get_point_count() > max_segments:
		$Segments.remove_point(0)

func get_head_diff() -> Vector2:
	print($Head.global_position, $Segments.points[$Segments.get_point_count() - 1])
	return $Head.global_position - $Segments.points[$Segments.get_point_count() - 1]

func handle_input():
	if not is_alive:
		return
	move_vector = Vector2(Input.get_axis(input_left,input_right),Input.get_axis(input_up,input_down))
