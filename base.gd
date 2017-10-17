extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var was_next_level_pr = false

export var current_level = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
	# load default level
	load_level("")
	
func next_level():
	current_level = (current_level) % 2
	current_level += 1
	
	load_level_num(current_level)

func restart_level():
	
	load_level_num(current_level)

			
# check for global input - change levels
func _fixed_process(delta):
	var next_level_pr = Input.is_action_pressed("level_1")
	
	if not was_next_level_pr and next_level_pr:
		call_deferred("next_level")
	
	was_next_level_pr = next_level_pr
	
func load_level_num(num):
	if num == 1:
		load_level("level-beta-1")
	elif num == 2:
		load_level("test-1")
	
# clear stage and load level
func load_level(name):
	
	if name == "":
		name = "level-beta-1"
	
	# clear stage
	var stage_children = get_node("stage").get_children()
	for ch in stage_children:
		get_node("stage").remove_child(ch)
	
	# Add player
	var player = preload("res://Player.tscn").instance()
		
	var level = null
	
	if name == "level-beta-1":
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
	return load("res://levels/level-beta-1.tscn").instance()
	
func load_level_2():
	return load("res://levels/test-1.tscn").instance()
