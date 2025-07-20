extends Node

var score_p1
var score_p2

var p1_length := 500
var p2_length := 500
var player_stun_time: float = 3.0

var snakes = []

var ui_game 
var resolution 
var aspect_ratio

var current_level

var levels = ["lvl0","lvl1","lvl2","lvl3"]

var lvl_index = 0

var last_killer = null

var dev_console_active = false

func _ready() -> void:
	score_p1 = 0
	score_p2 = 0
	ui_game = preload("res://scenes/ui_game.tscn").instantiate()
	get_parent().call_deferred("add_child", ui_game)
	Signals.connect("enemy_killed", on_enemy_killed)
	resolution = DisplayServer.screen_get_size()

	aspect_ratio = float(resolution.x) / float(resolution.y)
	print("aspect", aspect_ratio)
	
func on_enemy_killed(killer_player):
	print("enemy ded")
	print("killed by:", killer_player)
	if(current_level.enemies_remaining <= 0):
		print("no enemies left")
	var points = 50
	if(current_level.enemies_remaining <= 0):
		points += 950
	if(killer_player == 0):
		score_p1 += points
	elif(killer_player == 1):
		score_p2 += points
	last_killer = killer_player
	ui_game.update_scores()
		

func got_exploded(player):
	pass

func set_players_enabled(state):
	for player in snakes:
		player.paused = !state
		
func next_level():
	snakes.clear()
	current_level.queue_free()
	lvl_index += 1
	if(lvl_index >= levels.size()):
		lvl_index = 0
	
	if last_killer == 1:
		p2_length *= .8
		p2_length = max(p2_length,100)
		p1_length *= 1.2
		p1_length = min(p1_length,500)
	elif last_killer == 0:
		p1_length *= .8
		p1_length = max(p1_length,100)
		p2_length *= 1.2
		p2_length = min(p2_length,500)
		
	var scene_file = "res://scenes/%s.tscn" % levels[lvl_index]
	var scene = load(scene_file).instantiate()
	get_parent().call_deferred("add_child", scene)
	ui_game.set_level_complete(false)
	
func testfunc():
	print("game test function")
