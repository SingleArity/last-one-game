class_name Player
extends Node

var lengthf: float = 500.0;
var length: int:
	get():
		return round(lengthf)
	set(val):
		lengthf = val
var segment_length = 10;
var shrink_per_sec = 10;

var move_vector := Vector2.RIGHT
var move_speed = 400.0
var last_pos := Vector2.ZERO

var is_alive = true
var player_name = ""
var player_id = 0
var snake_color = Color.WHITE

var input_up = 'ui_up'
var input_down = 'ui_down'
var input_left = 'ui_left'
var input_right = 'ui_right'
var input_shoot = 'p1_shoot'
var input_bomb = 'p1_bomb' 

var has_bomb = true
var is_player = true

var bullet_scene = preload("res://bullet.tscn")
var splosion_scene = preload("res://splosion.tscn")

var paused = false

func _ready():
	Game.snakes.append(self)

func initialize(
	name: String,
	id: int,
	color: Color,
	initial_pos: Vector2,
	controls: Dictionary,
	inlength
):
	player_id = id
	player_name = name
	length = inlength
	
	$Head/ThingThatShoots.player = id
	snake_color = color
	$Head.global_position = initial_pos
	if id == 1:
		$Head/Sprite2D.texture = load("res://sprites/player2_test.png")
	# Set up controls
	input_up = controls.get("up", "")
	input_down = controls.get("down", "")
	input_left = controls.get("left", "")
	input_right = controls.get("right", "")
	input_shoot = controls.get("shoot", "")
	input_bomb = controls.get("bomb", "")
	
	var initial_segments = length / segment_length
	var point = Vector2.LEFT * length
	for i in range(initial_segments):
		point.x += segment_length
		$Segments.add_point(point)

func _process(_d):
	if(paused):
		#player paused, no takey input
		return
	handle_input()

func _physics_process(delta: float) -> void:

	if(paused):
		return
	if is_alive and is_player:
		$Head.velocity = move_vector * move_speed
		$Head.move_and_slide()
	
	var head_pos = $Head.global_position
	
	if $Segments.get_point_count() <= 0 and has_bomb:
		explode()
		return
	
	var head_diff := get_head_diff()
	while head_diff.length() >= segment_length:
		var head_segment = $Segments.points[$Segments.get_point_count() - 1]
		var new_pos = head_segment + head_diff.limit_length(segment_length)
		$Segments.add_point(new_pos)
		head_diff = get_head_diff()
	
	lengthf -= shrink_per_sec * delta
	var max_segments = length / segment_length;
	while $Segments.get_point_count() and $Segments.get_point_count() > max_segments:
		$Segments.remove_point(0)
	
	#handle_tail_collision()

func get_head_diff() -> Vector2:
	if $Segments.get_point_count() <= 0:
		return Vector2.ZERO
	return $Head.global_position - $Segments.points[$Segments.get_point_count() - 1]

func handle_input():
	if not is_alive or not is_player:
		return
		
	move_vector = Vector2(Input.get_axis(input_left,input_right),Input.get_axis(input_up,input_down))
	if move_vector.length() > 0:
		$Head.rotation = move_vector.angle()
	
	if Input.is_action_just_pressed(input_shoot):
		$Head/ThingThatShoots.try_shoot()
	
	if has_bomb and Input.is_action_just_pressed(input_bomb):
		drop_bomb()
		
func drop_bomb():
	print('drop bomb')
	if !is_alive or !has_bomb:
		return
	var new_player = duplicate()
	new_player.has_bomb = false
	new_player.length = 0
	is_player = false
	get_parent().add_child(new_player)
	Game.snakes[player_id] = new_player

func explode():
	has_bomb = false
	is_alive = false
	var expl = bullet_scene.instantiate()
	expl.is_bomb = true
	expl.scale_up(5)
	expl.velocity = 0.0
	var splosion = splosion_scene.instantiate()
	splosion.global_position = $Head.global_position
	splosion.add_child(expl)
	get_parent().add_child(splosion)
	
func got_exploded():
	if is_alive:
		Game.lose(player_id)

func handle_tail_collision(pos: Vector2, radius: float) -> bool:
	var rsq := radius * radius
	var collided_index = null
	for i in range(0, $Segments.get_point_count()):
		var point = $Segments.points[i]
		if (point - pos).length_squared() < rsq:
			collided_index = i
	if collided_index != null:
		$Segments.points = $Segments.points.slice(collided_index, $Segments.get_point_count())
		lengthf -= segment_length * collided_index
	return collided_index != null
