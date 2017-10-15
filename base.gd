extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var was_level_1_pr = false
var was_level_2_pr = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
	# load default level
	load_level("")
	
	
# check for global input - change levels
func _fixed_process(delta):
	var level_1_pr = Input.is_action_pressed("level_1")
	var level_2_pr = Input.is_action_pressed("level_2")
	
	if not was_level_1_pr and level_1_pr:
		load_level("SillyTestLevel")
	
	if not was_level_2_pr and level_2_pr:
		load_level("test-1")
	
	was_level_1_pr = level_1_pr
	was_level_2_pr = level_2_pr
	
# clear stage and load level
func load_level(name):
	
	if name == "":
		name = "SillyTestLevel"
	
	# clear stage
	var stage_children = get_node("stage").get_children()
	for ch in stage_children:
		get_node("stage").remove_child(ch)
	
	# Add player
	var player = preload("res://Player.tscn").instance()
		
	var level = null
	
	if name == "SillyTestLevel":
		level = load_level_1()
	elif name == "test-1":
		level = load_level_2()
	
	if level != null:
		get_node("stage").add_child(level)
		
		get_node("stage").add_child(player)
		
		player.set_pos(level.get_node("player_start").get_pos())
		level.get_node("player_start").hide()
		
		
	
# Level loading methods - since resource names can't be variables ?!?!
func load_level_1():
	return load("res://levels/SillyTestLevel.tscn").instance()
	
func load_level_2():
	return load("res://levels/test-1.tscn").instance()
