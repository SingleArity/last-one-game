extends CharacterBody2D

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
	
func change_state(new_state):
	var wait_low = 1.0
	var wait_high = 1.0
	match new_state:
		EnemyState.IDLE:
			wait_low = 1.0
			wait_high = 3.0
			move_direction = Vector2.ZERO
		EnemyState.MOVE:
			wait_low = 3.0
			wait_high = 6.0
			move_direction = Vector2(randf_range(-1.0,1.0),randf_range(-1.0,1.0))
		_:
			wait_low = 2.0
			wait_high = 4.0
			move_direction = Vector2.ZERO
	state_timer.wait_time = randf_range(wait_low,wait_high)
	state_timer.start()
	state = new_state

func on_enemy_shot(killer_player):
	Signals.emit_signal("enemy_killed", killer_player)
	Game.current_level.update_enemies(get_tree().get_nodes_in_group("enemies").size()-1)
	queue_free()

func _on_timer_timeout() -> void:
	match state:
		EnemyState.IDLE:
			change_state(EnemyState.MOVE)
			print("change to move!")
		EnemyState.MOVE:
			change_state(EnemyState.IDLE)
			print("change to idle")
