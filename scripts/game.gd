extends Node

var aspect_ratio

var score_p1
var score_p2

var p1_length := 500
var p2_length := 500
var player_stun_time: float = 5.0

var snakes = []

var ui_game 

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
	
func on_enemy_killed(killer_player):
	print("enemy ded")
	var points = 50
	if(current_level.enemies_remaining == 1):
		points += 950
	if(killer_player == 0):
		score_p1 += points
	elif(killer_player == 1):
		score_p2 += points
	last_killer = killer_player
	ui_game.update_scores()

func got_exploded(player):
	if(player == 0):
		score_p1 -= 1000
	elif(player == 1):
		score_p2 -= 1000
	ui_game.update_scores()

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
	elif last_killer == 0:
		p1_length *= .8
		
	var scene_file = "res://scenes/%s.tscn" % levels[lvl_index]
	var scene = load(scene_file).instantiate()
	get_parent().call_deferred("add_child", scene)
	ui_game.set_level_complete(false)
	
func testfunc():
	print("game test function")
	
