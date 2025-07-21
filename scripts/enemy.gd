extends CharacterBody2D

const last_one_mat = preload("res://sprites/fx/special_mat.tres")
const confetti_scene = preload("res://sprites/fx/confetti.tscn")

@onready var state_timer = $Timer

@export var move_speed: float

var move_direction

enum EnemyState{
	IDLE,
	MOVE,
	MOVE_TO_TARGET
}

var target
var state: EnemyState

var wait_low_d := 1.0
var wait_high_d := 6.0
var wait_low_idle := 1.0
var wait_high_idle := 3.0
var wait_low_move := 3.0
var wait_high_move := 6.0
var wait_low_target := 2.0
var wait_high_target := 4.0
var wait_mult := 1.0

var is_last_one := false

func _ready():
	change_state(EnemyState.IDLE)
	
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	match state:
		EnemyState.IDLE:
			pass
		EnemyState.MOVE:
			velocity = move_direction * move_speed
			move_and_slide()
			
			if is_last_one and get_slide_collision_count() > 0:
				print('picking a new direction')
				change_state(EnemyState.MOVE)

func change_state(new_state):
	var wait_low = wait_low_d
	var wait_high = wait_high_d
	match new_state:
		EnemyState.IDLE:
			wait_high = wait_high_idle
			move_direction = Vector2.ZERO
		EnemyState.MOVE:
			wait_low = wait_low_move
			wait_high = wait_high_move
			move_direction = Vector2.RIGHT.rotated(randf_range(-PI, PI))
		_:
			wait_low = wait_low_target
			wait_high = wait_high_target
			move_direction = Vector2.ZERO
	wait_low *= wait_mult
	wait_high *= wait_mult
	state_timer.wait_time = randf_range(wait_low,wait_high)
	state_timer.start()
	state = new_state

func on_enemy_shot(killer_player):
	Game.current_level.enemies_remaining -= 1
	Signals.emit_signal("enemy_killed", killer_player)
	print("enemies left:")
	print(Game.current_level.enemies_remaining)
	Game.current_level.update_enemies(Game.current_level.enemies_remaining)
	queue_free()

	if Game.current_level.enemies_remaining == 1:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy != self:
				enemy.last_one()
	elif Game.current_level.enemies_remaining == 0:
		var confetti: GPUParticles2D = confetti_scene.instantiate()
		confetti.emitting = true
		confetti.global_position = global_position
		get_parent().add_child(confetti)

func _on_timer_timeout() -> void:
	match state:
		EnemyState.IDLE:
			change_state(EnemyState.MOVE)
			print("change to move!")
		EnemyState.MOVE:
			if is_last_one:
				change_state(EnemyState.MOVE)
				print("keep moving!")
			else:
				change_state(EnemyState.IDLE)
				print("change to idle")

func last_one():
	print("last one!")
	$AnimatedSprite2D.material = last_one_mat
	move_speed *= 3
	wait_mult = 0.3
	is_last_one = true
	
