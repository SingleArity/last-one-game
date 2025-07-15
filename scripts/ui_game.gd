extends Control

@onready var game = get_node("/root/Game")

@onready var score1 = $VBoxContainer/HBoxContainer/Score1
@onready var score2 = $VBoxContainer/HBoxContainer/Score2

@onready var level_complete = $VBoxContainer/HBoxContainer2/LevelComplete
@onready var continue_text = $VBoxContainer/HBoxContainer3/continue

func _ready():
	update_scores()

func update_scores():
	score1.text = "P1 Score\n%s" % game.score_p1
	score2.text = "P2 Score\n%s" % game.score_p2
	
func set_level_complete(state):
	level_complete.visible = state
	continue_text.visible = state

func _process(delta):
	if(Input.is_action_just_pressed("dev_console")):
		if(!$DevConsole.active):
			$DevConsole.visible = true
			$DevConsole.set_active(true)
		else:
			$DevConsole.visible = false
			$DevConsole.set_active(false)
