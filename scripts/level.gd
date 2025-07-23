extends Node2D

@onready var game = get_node("/root/Game")

const STEP_TIME = 0.15
const STARTING_GRID_X = 5
const STARTING_GRID_Y = 5

var step_timer = 0.0

var total_enemies
var enemies_remaining

var game_over = false
var level_complete

func _ready():
	scale_level(Game.resolution, Game.aspect_ratio)
	
	level_complete = false
	game.current_level = self
	
	total_enemies = get_tree().get_nodes_in_group("enemies").size()
	enemies_remaining = total_enemies
	
	# Initialize players with different starting positions and controls
	if Game.snakes.size() >= 1:
		Game.snakes[0].initialize(
			"Player 1",
			0,
			Color.BLUE,
			$P1_Spawn.global_position,
			{"up": "ui_up", "down": "ui_down", "left": "ui_left", "right": "ui_right", 'shoot': 'p1_shoot', 'bomb': 'p1_bomb', 'pause': 'p1_pause'},
			Game.p1_length
		)
		
	
	if Game.snakes.size() >= 2:
		Game.snakes[1].initialize(
			"Player 2", 
			1,
			Color.BLUE_VIOLET,
			$P2_Spawn.global_position,
			{"up": "p2_up", "down": "p2_down", "left": "p2_left", "right": "p2_right", 'shoot': 'p2_shoot', 'bomb': 'p2_bomb', 'pause': 'p2_pause'},
			Game.p2_length
		)
	
	# Initialize additional players with default controls if more exist
	for i in range(2, Game.snakes.size()):
		Game.snakes[i].initialize(
			"Player " + str(i + 1),
			i,
			Color(randf(), randf(), randf()),  # Random color
			Vector2.ZERO,
			{"up": "", "down": "", "left": "", "right": ""},  # No controls - AI could go here,
			500
		)
	
	#pause players, will wait for ready up from each
	for i in range(0,Game.snakes.size()):
		Game.snakes[i].paused = true
	Game.set_state_ready()

func _process(delta):
	if(level_complete):
		if(Input.is_action_just_pressed("p1_shoot") || Input.is_action_just_pressed("p2_shoot")):
			game.next_level()
	if game_over:
		return


func _physics_process(delta):
	if game_over:
		return

func check_game_over():
	var alive_players = 0
	var winner = null
	
	for snake in Game.snakes:
		if snake.is_alive:
			alive_players += 1
			winner = snake
	
	# Only end game if there are multiple players and only one (or none) remains alive
	# OR if there's only one snake and it died
	if Game.snakes.size() > 1 and alive_players <= 1:
		game_over = true
		print("Game Over!")
		if alive_players == 1:
			print("Winner: ", winner.player_name)
		else:
			print("It's a tie!")
	elif Game.snakes.size() == 1 and alive_players == 0:
		game_over = true
		print("Game Over!")
		print("Snake died!")
		
func update_enemies(new_total):
	total_enemies = new_total
	enemies_remaining = total_enemies
	if(new_total <= 0):
		print("LEVEL END")
		level_complete = true
		game.ui_game.set_level_complete(true)
		game.set_players_enabled(false)

#this whole function assumes a screen/viewport that is wider than it is tall
func scale_level(resolution, aspect):
	var x_stretch = float(resolution.x) / 720.0
	var y_stretch = float(resolution.y) / 720.0
	
	var viewport_size = get_tree().root.size
	var stretch_ratio = float(viewport_size.x) / float(viewport_size.y)
	print(stretch_ratio)

	#Position and Scale Walls

	$WallRight.position.x = (720.0 * stretch_ratio) - 64.0 #32.0
	$WallRight/CollisionShape2D.shape.size.y = resolution.y
	
	$WallBottom.position.x = (360.0 * stretch_ratio)
	$WallBottom/CollisionShape2D.shape.size.x = resolution.x

	$WallTop.position.x = (360.0 * stretch_ratio)
	$WallTop/CollisionShape2D.shape.size.x = resolution.x

	$LevelEnvironment/Walls.size.x = 720.0 * stretch_ratio - 40
	
	
	#Position Objects
	$P1_Spawn.position.x = ($P1_Spawn.position.x * stretch_ratio)
	$P2_Spawn.position.x = ($P2_Spawn.position.x * stretch_ratio)

	for en in get_tree().get_nodes_in_group("enemies"):
		en.position.x = (en.position.x * stretch_ratio)
	
	#UI
	Game.ui_game.size.x = 720.0 * stretch_ratio
	Game.ui_game.get_node("VBoxContainer").size.x = 720.0 * stretch_ratio
