extends Marker2D

@export var bullet_scene: PackedScene
@export var cooldown_sec: float = .1
@export var reload_sec: float = .5
@export var max_bullets: int
@export var player := 0

@onready var player_ui
@onready var bullets
var is_cooled = true

func _ready():
	$Cooldown.wait_time = cooldown_sec
	$Reload.wait_time = reload_sec

func try_shoot():
	var can_shoot = is_cooled && bullets > 0
	if can_shoot:
		shoot()

func shoot():
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.rotation = global_rotation
	bullet.position = global_position
	bullet.player = player
	get_node('/root').add_child(bullet)
	is_cooled = false
	bullets -= 1
	#Game.snakes[player].ammo_current -= 1
	player_ui.update_bullets(bullets)
	$Cooldown.start()
	$Reload.start()

func _on_reload_timeout() -> void:
	bullets = clamp(bullets + 1, 0, max_bullets)
	player_ui.update_bullets(bullets)
	$Reload.start()

func _on_cooldown_timeout() -> void:
	is_cooled = true
