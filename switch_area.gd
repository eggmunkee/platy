extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var is_on = false
var switch_timer = 0.0

signal switch_input(input_value)


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func _fixed_process(delta):
	if switch_timer > 0.0:
		switch_timer -= delta

func input_signal(input_value):
	is_on = input_value
	update_frame()

func toggle_switch():
	if switch_timer <= 0.0:
		is_on = not is_on
		switch_timer = 0.3
		update_frame()
			
		emit_signal("switch_input", is_on)
	
func update_frame():
	var spr = get_node("Sprite")
	if is_on:
		spr.set_frame(0)
	else:
		spr.set_frame(1)

func _on_switch_area_body_enter( body ):
	
	if body extends preload("res://player.gd") or body extends preload("res://bottle_proj.gd") or body extends preload("res://rock.gd"):

		toggle_switch()
	