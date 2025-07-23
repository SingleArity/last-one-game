extends Control

@export var num_bullets: int
@export var bullet_scene: PackedScene

func _ready() -> void:
	print("player_ui ready ", get_node("../..").name)
	if($Bullets.get_child_count() == 0):
		arrange_bullets(num_bullets)
	
func arrange_bullets(num):
	var angle_diff = (2*PI) / num
	var angle = 0.0
	for i in range(num):
		#hypotenuse = 20
		#angle = angle 
		var x = 20 * cos(angle)
		var y = 20 * sin(angle)
		var bullet_pos = Vector2(x,y)
		angle += angle_diff
		var new_bullet = bullet_scene.instantiate()
		new_bullet.position = bullet_pos
		$Bullets.add_child(new_bullet)
		
func update_bullets(ammo_amt):
	print("update bullets amt ", ammo_amt )
	for i in range(num_bullets):
		if(i < ammo_amt):
			$Bullets.get_child(i).animation = "available"
		else:
			$Bullets.get_child(i).animation = "out"

func set_ready():
	$Readied.play("ready")
	
func start_level():
	$Readied.visible = false
