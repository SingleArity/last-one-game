class_name Player
extends Node

const GameState = preload("res://scripts/gamestate.gd")

var readied_up = false
var paused = false

var lengthf: float = 500.0;
var length: int:
	get():
		return round(lengthf)
	set(val):
		lengthf = val
var segment_length = 10;
var shrink_per_sec = 30;

var move_vector := Vector2.ZERO
var facing_vector := Vector2(1,0)
var move_speed = 400.0
var last_pos := Vector2.ZERO

var is_alive = true
var player_name = ""
var player_id = 0
var player_array_position
var snake_color = Color.WHITE

var input_up = 'ui_up'
var input_down = 'ui_down'
var input_left = 'ui_left'
var input_right = 'ui_right'
var input_shoot = 'p1_shoot'
var input_bomb = 'p1_bomb' 
var input_pause = 'p1_pause'

var ammo_total = 5
var ammo_current

var powering_push = false
var push_power = 0
var push_power_max = 200

var player_ui_scene = preload("res://scenes/ui_player.tscn")
var ui_player

var has_bomb = true
var is_player = true
var stunned = false
var stunned_time: float = 0.0

var bullet_scene = preload("res://bullet.tscn")
var splosion_scene = preload("res://splosion.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")


var max_rotation = deg_to_rad(360)

func _ready():
	Game.snakes.append(self)
	#array pos should be last index
	player_array_position = Game.snakes.size() - 1
	
func set_controls(player_id):
	var controls = {"up": "ui_up", "down": "ui_down", "left": "ui_left", "right": "ui_right", 'shoot': 'p1_shoot', 'bomb': 'p1_bomb', 'pause': 'p1_pause'}
	if(player_id == 1):
		controls = {"up": "p2_up", "down": "p2_down", "left": "p2_left", "right": "p2_right", 'shoot': 'p2_shoot', 'bomb': 'p2_bomb', 'pause': 'p2_pause'}
	input_up = controls.get("up", "")
	input_down = controls.get("down", "")
	input_left = controls.get("left", "")
	input_right = controls.get("right", "")
	input_shoot = controls.get("shoot", "")
	input_bomb = controls.get("bomb", "")
	input_pause = controls.get("pause", "")
	
func init_bullets_ui():
	#ui_player = player_ui_scene.instantiate()
	ui_player = $Head/UI_Player
	ui_player.num_bullets = ammo_current
	ui_player.position = Vector2(0,0)
	#$Head.add_child(ui_player)
	$Head/ThingThatShoots.player_ui = ui_player
	$Head/ThingThatShoots.max_bullets = ammo_total
	$Head/ThingThatShoots.bullets = ammo_current
	print("init bullet ui, ammo ", ammo_current)
	ui_player.update_bullets(ammo_current)
	print("post init")
	
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
	input_pause = controls.get("pause", "")
	
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
	
	$Fuse.global_position = $Head.global_position

func _process(d):
	
	if(paused):
		#handle 'readied up' status
		if(Game.state == GameState.READY_UP):
			if(is_any_player_action_just_pressed() and !readied_up):
				ui_player.set_ready()
				readied_up = true
				Game.check_all_players_ready()
		#player paused, no takey regular input
		return
	if(stunned):
		move_vector = Vector2(0,0)
		stunned_time -= d
		#un-stun
		if(stunned_time <= 0.0):
			stunned_time = 0.0
			stunned = false
			$Head/Sprite.animation = "idle_%s" % player_id
		return
	handle_input(d)

func is_any_player_action_just_pressed():
	return (Input.is_action_just_pressed(input_up) || Input.is_action_just_pressed(input_down)
	|| Input.is_action_just_pressed(input_left) || Input.is_action_just_pressed(input_right)
	|| Input.is_action_just_pressed(input_shoot) || Input.is_action_just_pressed(input_bomb)
	|| Input.is_action_just_pressed(input_pause))
			
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
		var head_segment = $Segments.points[$Segments.get_point_count() - 1]
		var new_pos = head_segment + head_diff.limit_length(segment_length)
		$Segments.add_point(new_pos)
		head_diff = get_head_diff()
	
	lengthf -= shrink_per_sec * delta
	var max_segments = ceil(lengthf / segment_length);
	
	while $Segments.get_point_count() and $Segments.get_point_count() > max_segments:
		$Segments.remove_point(0)
	
	# smooth tail shrinkage
	if $Segments.get_point_count() >= 2:
		var tail_tip: Vector2 = $Segments.points[0]
		var tail_tip_seg: Vector2 = $Segments.points[1] - tail_tip
		var tail_tip_len = tail_tip_seg.length()
		var visible_length = $Segments.get_point_count() * segment_length - (segment_length - tail_tip_len)
		if visible_length > lengthf:
			var to_subtract: float = tail_tip_len - fmod(lengthf, segment_length)
			$Segments.points[0] = tail_tip.move_toward($Segments.points[1], to_subtract)
	
	$Fuse.global_position = $Segments.points[0] if $Segments.get_point_count() else $Head.global_position

	if(powering_push):
		push_power_increase()
		
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
		#$Head.rotation = move_vector.angle()
		
		#$Head.rotation = lerp_angle($Head.rotation, move_vector.angle(), .1)
		facing_vector = move_vector
	if abs($Head.rotation - facing_vector.angle()) > (.75*PI):
		$Head.rotation = lerp_angle($Head.rotation, facing_vector.angle(), .75)
	else:
		$Head.rotation = lerp_angle($Head.rotation, facing_vector.angle(), .25)
	
	if Input.is_action_just_pressed(input_shoot):
		$Head/ThingThatShoots.try_shoot()
	
	if has_bomb and Input.is_action_just_pressed(input_bomb):
		drop_bomb()
	
	if !has_bomb and Input.is_action_just_pressed(input_bomb):
		powering_push = true
		$Head/Sprite.play("push_%s" % player_id)
		$Head/Left.disabled = true
		$Head/Right.disabled = true
	if !has_bomb and Input.is_action_just_released(input_bomb):
		powering_push = false
		$Head/Sprite.play("bombless_%s" % player_id)
		$Head/Left.disabled = false
		$Head/Right.disabled = false
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var pushdir = Vector2.from_angle($Head.rotation)
			enemy.check_apply_push(self, push_power, pushdir)
		push_power = 0
		
func push_power_increase():
	push_power = 100
	#push_power += 1
	#push_power = min(push_power,push_power_max)
	
func drop_bomb():
	#remove existing player from game players list
	Game.snakes.remove_at(player_id)
	if !is_alive or !has_bomb:
		return
	var new_player = duplicate(7)
	new_player.has_bomb = false
	new_player.length = 0
	#shrink_per_sec = 200
	$Head/Sprite.play("bomb_%s" % player_id)
	is_player = false
	new_player.player_id = player_id
	get_parent().add_child(new_player)
	new_player.set_controls(player_id)
	new_player.ammo_current = ammo_current
	print("AMMO ", ammo_current)
	new_player.init_bullets_ui()
	Game.snakes[player_id] = new_player
	Game.snakes.append(self)
	player_array_position = Game.snakes.size() - 1
	new_player.get_node('Fuse').emitting = false
	new_player.get_node("Head/Sprite").play("bombless_%s" % player_id)

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
	$Fuse.emitting = false
	
func got_exploded():
	if is_alive && is_player:
		Game.got_exploded(player_id)
		#is_alive = false
		stunned = true
		stunned_time += Game.player_stun_time
		$Head/Sprite.play("stun_%s" % player_id)
	if(!is_player):
		Game.snakes.remove_at(player_array_position)
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
