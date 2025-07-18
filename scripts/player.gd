class_name Player
extends Node

var lengthf: float = 500.0;
var length: int:
	get():
		return round(lengthf)
	set(val):
		lengthf = val
var segment_length = 10;
var shrink_per_sec = 30;

var move_vector := Vector2.ZERO
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

var ammo_total = 5
var ammo_current

var player_ui_scene = preload("res://scenes/ui_player.tscn")
var ui_player

var has_bomb = true
var is_player = true
var stunned = false
var stunned_time: float = 0.0

var bullet_scene = preload("res://bullet.tscn")
var splosion_scene = preload("res://splosion.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")

var paused = false

var max_rotation = deg_to_rad(360)

func _ready():
	Game.snakes.append(self)
	
func set_controls(player_id):
	var controls = {"up": "ui_up", "down": "ui_down", "left": "ui_left", "right": "ui_right", 'shoot': 'p1_shoot', 'bomb': 'p1_bomb'}
	if(player_id == 1):
		controls = {"up": "p2_up", "down": "p2_down", "left": "p2_left", "right": "p2_right", 'shoot': 'p2_shoot', 'bomb': 'p2_bomb'}
	input_up = controls.get("up", "")
	input_down = controls.get("down", "")
	input_left = controls.get("left", "")
	input_right = controls.get("right", "")
	input_shoot = controls.get("shoot", "")
	input_bomb = controls.get("bomb", "")

func init_bullets_ui():
	ui_player = player_ui_scene.instantiate()
	ui_player.num_bullets = ammo_current
	ui_player.position = Vector2(0,0)
	$Head.add_child(ui_player)
	$Head/ThingThatShoots.player_ui = ui_player
	$Head/ThingThatShoots.max_bullets = ammo_total
	$Head/ThingThatShoots.bullets = ammo_current
	ui_player.update_bullets(ammo_current)
	
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
		$Head/Sprite.animation = "idle_1"
	# Set up controls
	
	input_up = controls.get("up", "")
	input_down = controls.get("down", "")
	input_left = controls.get("left", "")
	input_right = controls.get("right", "")
	input_shoot = controls.get("shoot", "")
	input_bomb = controls.get("bomb", "")
	
	$Segments.add_point($Head.global_position)
	
	ammo_current = ammo_total
	
	ui_player = player_ui_scene.instantiate()
	ui_player.num_bullets = ammo_current
	ui_player.position = Vector2(0,0)
	$Head.add_child(ui_player)
	$Head/ThingThatShoots.player_ui = ui_player
	$Head/ThingThatShoots.max_bullets = ammo_total
	$Head/ThingThatShoots.bullets = ammo_current
	ui_player.update_bullets(ammo_current)

func _process(d):
	
	if(paused):
		#player paused, no takey input
		return
	if(stunned):
		stunned_time -= d
		#un-stun
		if(stunned_time <= 0.0):
			stunned_time = 0.0
			stunned = false
			$Head/Sprite.animation = "idle_%s" % player_id
		return
	handle_input(d)

func _physics_process(delta: float) -> void:

	if(paused):
		return
	
	var old_pos: Vector2 = $Head.global_position
	if is_alive and is_player:
		$Head.velocity = move_vector * move_speed
		$Head.move_and_slide()
	
	var head_pos: Vector2 = $Head.global_position
	
	if $Segments.get_point_count() <= 0 and has_bomb:
		explode()
		return
	
	var head_diff := get_head_diff()
	var distance_moved := head_pos - old_pos
	var moved = not distance_moved.is_equal_approx(Vector2.ZERO)
	while moved and head_diff.length() >= segment_length:
		print('moved')
		var head_segment = $Segments.points[$Segments.get_point_count() - 1]
		var new_pos = head_segment + head_diff.limit_length(segment_length)
		$Segments.add_point(new_pos)
		head_diff = get_head_diff()
	
	lengthf -= shrink_per_sec * delta
	var max_segments = ceil(lengthf / segment_length);
	
	while $Segments.get_point_count() and $Segments.get_point_count() > max_segments:
		$Segments.remove_point(0)
	
	if $Segments.get_point_count() >= 2:
		var tail_tip: Vector2 = $Segments.points[0]
		var tail_tip_seg: Vector2 = $Segments.points[1] - tail_tip
		var tail_tip_len = tail_tip_seg.length()
		var visible_length = $Segments.get_point_count() * segment_length - (segment_length - tail_tip_len)
		if visible_length > lengthf:
			var to_subtract: float = tail_tip_len - fmod(lengthf, segment_length)
			$Segments.points[0] = tail_tip.move_toward($Segments.points[1], to_subtract)
		
		
	#handle_tail_collision()

func get_head_diff() -> Vector2:
	if $Segments.get_point_count() <= 0:
		return Vector2.ZERO
	return $Head.global_position - $Segments.points[$Segments.get_point_count() - 1]

func handle_input(delta):
	if not is_alive or not is_player or Game.dev_console_active:
		return
	
	var h = Input.get_axis(input_left,input_right)
	var v = Input.get_axis(input_up,input_down)
	move_vector = Vector2(h,v)
	if (move_vector.length() > 0):
		#var diff = angle_difference(move_vector.angle(), prev_move_vector.angle())
		#var limit = max_rotation*delta
		#var clamped = clamp(-diff, -limit, limit)
		#if clamped:
			#print(clamped)
		#prev_move_vector = prev_move_vector.rotated(clamped)
		#move_vector = prev_move_vector
		$Head.rotation = move_vector.angle()
	
	if Input.is_action_just_pressed(input_shoot):
		$Head/ThingThatShoots.try_shoot()
	
	if has_bomb and Input.is_action_just_pressed(input_bomb):
		drop_bomb()
		
func drop_bomb():
	#remove existing player from game players list
	Game.snakes.remove_at(player_id)
	if !is_alive or !has_bomb:
		return
	var new_player = duplicate(7)
	new_player.has_bomb = false
	new_player.length = 0
	shrink_per_sec = 200
	is_player = false
	new_player.player_id = player_id
	get_parent().add_child(new_player)
	new_player.set_controls(player_id)
	new_player.ammo_current = ammo_current
	new_player.init_bullets_ui()
	Game.snakes[player_id] = new_player

func explode():
	has_bomb = false
	#is_alive = false
	var expl = bullet_scene.instantiate()
	expl.is_bomb = true
	expl.scale_up(5)
	expl.velocity = 0.0
	expl.get_node("Sprite2D").visible = false
	var splosion = splosion_scene.instantiate()
	splosion.global_position = $Head.global_position
	splosion.add_child(expl)
	splosion.get_node("AnimatedSprite2D").play("default")
	get_parent().add_child(splosion)
	
func got_exploded():
	if is_alive && is_player:
		Game.got_exploded(player_id)
		#is_alive = false
		stunned = true
		stunned_time += Game.player_stun_time
		$Head/Sprite.play("stun_%s" % player_id)
	if(!is_player):
		queue_free()

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
