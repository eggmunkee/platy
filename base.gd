extends Node2D

var was_next_level_pr = false
var was_pause_pr = false

var the_level = null
var level_loader = null
var is_loading = false

var need_restart = false
var need_next_level = false

export var current_level = 1

var level_list = ["level-1","level-2","level-beta-1", "level-beta-2", "SillyTestLevel", "level-bg-test"]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	_on_screen_resized()
	
	
	# load default level
	update_ui_level()
	load_level("")
	
func update_ui_level():
	var level_num_str = "0" + str(current_level)
	level_num_str = level_num_str.substr(level_num_str.length() - 2, 2)
	get_node("ui/top_panel/level_num").set_text(level_num_str)
	
func update_paused(is_paused):
	get_tree().set_pause(is_paused)
	get_node("ui/top_panel/paused").set_hidden(not is_paused)
	
func update_hearts(num):
	
	var i = 0
	for heart in get_node("ui/top_panel/hearts").get_children():
		i += 1
		if num < i:
			heart.hide()
		else:
			heart.show()
	
func restart_level():
	need_restart = true
	
func next_level():
	need_next_level = true
	
func _next_level():
	current_level = (current_level) % level_list.size()
	current_level += 1
	
	load_level_num(current_level)

func _restart_level():
	
	level_loader = null
	is_loading = false
	the_level = null
	load_level_num(current_level)

			
# check for global input - change levels
func _fixed_process(delta):
	
	if need_next_level or need_restart:
		
		if need_next_level:
			need_next_level = false
			_next_level()
			
		elif need_restart:
			need_restart = false
			_restart_level()
		
		return
	
	var next_level_pr = Input.is_action_pressed("level_1")
	var quit_pr = Input.is_action_pressed("quit")
	var pause_pr = Input.is_action_pressed("pause")
	
	# Quit handling
	if quit_pr:
		get_tree().quit()
		
	if is_loading and level_loader != null:
		var resp = level_loader.poll()
		
		if resp == OK:
			print("loading... (", level_loader.get_stage())
		elif resp == ERR_FILE_EOF:
			var try_level = level_loader.get_resource()
			
		
			if try_level:
				the_level = try_level.instance()
				call_deferred("_real_load")
			else:
				print("Failure..")
		
			is_loading = false
			level_loader = null
	else:
	
		# Pause handling
		if pause_pr and not was_pause_pr:
			var is_paused = not get_tree().is_paused()
			update_paused(is_paused)
		
		if not is_loading and not was_next_level_pr and next_level_pr:
			call_deferred("next_level")
		
		was_next_level_pr = next_level_pr
		was_pause_pr = pause_pr
	
func load_level_num(num):
	var lev_ind = num - 1
	
	if lev_ind < level_list.size():
		update_ui_level()
		load_level(level_list[lev_ind])
		
	
# clear stage and load level
func load_level(name):
	
	if name == "":
		name = level_list[0]
	
	_load_level_name(name)
		
func _real_load():
	
	# clear stage
	var level = the_level
	
	var stage_children = get_node("stage").get_children()
	for ch in stage_children:
		#if true or not ch extends preload("res://player.gd"):
		get_node("stage").remove_child(ch)
		#else:
		#	player = ch
	
	if level:
	
		# add level/player
		var player = preload("res://player.tscn").instance()
	
		get_node("stage").add_child(level)
		get_node("stage").add_child(player)
		
		player.get_node("player_cam").make_current()
			
		player.set_pos(level.get_node("player_start").get_pos())
		#player.respawn()
		#level.get_node("player_start").hide()
	
# Level loading method
func _load_level_name(name):
	var res_path = "res://levels/" + name + ".tscn"
	#is_loading = true
	the_level = null
	the_level = ResourceLoader.load(res_path).instance()
	_real_load()
	
	


func _on_screen_resized():
	var vp_rect = get_viewport_rect()
	var top_panel = get_node("ui/top_panel")
	var curr_height = top_panel.get_size().y
	top_panel.set_size(Vector2(vp_rect.size.width-14, curr_height))
	var paused_label = get_node("ui/top_panel/paused")
	var curr_paused_y = paused_label.get_pos().y
	paused_label.set_pos(Vector2((top_panel.get_size().x - paused_label.get_size().x) / 2, curr_paused_y))
