extends Node2D

var game_over = false

func _ready():
	# Initialize players with different starting positions and controls
	if Game.snakes.size() >= 1:
		Game.snakes[0].initialize(
			"Player 1", 
			Color.BLUE,
			$P1_Spawn.global_position,
			{"up": "ui_up", "down": "ui_down", "left": "ui_left", "right": "ui_right", 'shoot': 'p1_shoot'}
		)
		
	
	if Game.snakes.size() >= 2:
		Game.snakes[1].initialize(
			"Player 2", 
			Color.BLUE_VIOLET,
			$P2_Spawn.global_position,
			{"up": "p2_up", "down": "p2_down", "left": "p2_left", "right": "p2_right", 'shoot': 'p2_shoot'}
		)
	
	# Initialize additional players with default controls if more exist
	for i in range(2, Game.snakes.size()):
		Game.snakes[i].initialize(
			"Player " + str(i + 1),
			Color(randf(), randf(), randf()),  # Random color
			Vector2.ZERO,
			{"up": "", "down": "", "left": "", "right": ""},  # No controls - AI could go here
		)

func _process(delta):
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
