extends VBoxContainer

var active = false

# COMMANDS
#
## SET 
## set game variable value
## set path/to/node variable value
#
## CALL
## call game functionname
## call path/to/node functionname [optional parameter]
#
var cmds = {
	"set": "set_var",
	"call": "call_func"
}

func set_active(state):
	active = state
	if(state):
		$Line.grab_focus()

func _on_line_text_submitted(new_text: String) -> void:
	if(active):
		register_command(new_text)
	
func register_command(text):
	print("registered: ", text)
	var text_split = text.split(" ")
	var cmd = text_split[0]
	print("command: ", cmd)
	match text_split.size():
		3:
			call(cmds[cmd], text_split[1], text_split[2])
		4:
			call(cmds[cmd], text_split[1], text_split[2], text_split[3])
			
func set_var(classname, var_name, value):
	if(classname == "game" or classname == "Game"):
		Game.set(var_name,value)
	else:
		get_node(classname).set(var_name,value)
	
func call_func(script, funcname, extra_param = null):
	if(script == "game" or script == "Game"):
		Game.call(funcname)
	else:
		if(extra_param == null):
			get_node(script).call(funcname)
		else:
			get_node(script).call(funcname,extra_param)
