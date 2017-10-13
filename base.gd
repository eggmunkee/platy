extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	load_level("")
	
	
func load_level(name):
	
	if name != "":
		name = "SillyTestLevel"
	
	# clear stage
	var stage_children = get_node("stage").get_children()
	for ch in stage_children:
		get_node("stage").remove_child(ch)
	
	# Add player
	var player = preload("res://Player.tscn").instance()
	get_node("stage").add_child(player)
	
	# ADd level
	#var res_path = "res://levels/" + name + ".tscn"
	var level = load("res://levels/SillyTestLevel.tscn").instance()
	#var level = load("res://levels/test-1.tscn").instance()
	get_node("stage").add_child(level)
	
	player.set_pos(level.get_node("player_start").get_pos())
	level.get_node("player_start").hide()
	
