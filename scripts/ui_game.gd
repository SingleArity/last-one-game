extends Control

@onready var game = get_node("/root/Game")

func _ready():
	update_scores()

func update_scores():
	$HBoxContainer/Score1.text = "P1 Score\n%s" % game.score_p1
	$HBoxContainer/Score2.text = "P2 Score\n%s" % game.score_p2
