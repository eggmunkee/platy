extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var leak_rate = 0.5
export var initial_velocity = Vector2(0.0,0.0)
var leak_timer = leak_rate
export var is_on = true


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	if is_on:
		leak_timer -= delta
		
		if leak_timer < 0.0:
			leak()
			leak_timer += leak_rate
	
func input_value(new_value):
	is_on = new_value
	
func leak():
	var oil = preload("res://entities/oil_proj.tscn").instance()
	var start_pos = get_node("leak_spot").get_pos()
	start_pos = start_pos + get_pos()
	oil.set_pos(start_pos)
	
	var bottle_lin_vel = initial_velocity

	bottle_lin_vel.x *= rand_range(0.7,1.3)
	bottle_lin_vel.y *= rand_range(0.8, 1.2)
	
	oil.set_linear_velocity(bottle_lin_vel)
	get_parent().add_child(oil)
	
	if rand_range(0.0, 1.0) > 1.90:
		oil.burn()
	
