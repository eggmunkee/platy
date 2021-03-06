extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var x_velocity = 0.0
export var y_velocity = 0.0
export var is_falling = true
var no_pickup_timer = 0.0
var time_since_fall = 0.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func stop():
	is_falling = false
	time_since_fall = 0.0
	
func toss(right):
	is_falling = true
	no_pickup_timer = 0.6
	x_velocity = 100.0
	y_velocity = 15.0
	time_since_fall = 0.0
	if not right:
		x_velocity = -x_velocity
	
func _fixed_process(delta):
	if no_pickup_timer > 0.0:
		no_pickup_timer -= delta
		
	if is_falling:
		var pos = get_pos()
		pos.x += x_velocity * delta
		pos.y += y_velocity * delta
		set_pos(pos)
		
		if y_velocity < 500.0:
			y_velocity += 200.0 * delta
	# Keep track of time since landing up to 10 seconds
	elif time_since_fall < 10.0:
		time_since_fall += delta
			
	for o_body in get_overlapping_bodies():
		if o_body extends preload("res://player.gd"):
			if no_pickup_timer <= 0.0:
				on_player_overlap(o_body)
			
		elif o_body extends RigidBody2D or o_body extends StaticBody2D:
			is_falling = false
			on_body_overlap(o_body)
			
func on_player_overlap(player):
	
	pass
	
func on_body_overlap(body):
	pass
