extends Node

@onready var signals = get_node("/root/Signals")

var score_p1
var score_p2

var snakes = []

var ui_game 

var current_level

func _ready() -> void:
	score_p1 = 0
	score_p2 = 0
	ui_game = preload("res://scenes/ui_game.tscn").instantiate()
	get_parent().call_deferred("add_child", ui_game)
	signals.connect("enemy_killed", on_enemy_killed)
	
func on_enemy_killed(killer_player):
	print("enemy ded")
	var points = 50
	if(current_level.enemies_remaining == 1):
		points += 1000
	if(killer_player == 0):
		score_p1 += points
	elif(killer_player == 1):
		score_p2 += points
	ui_game.update_scores()
