extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_thrown = false
var x_velocity = 300.0
var y_velocity = 25.0
var life = 25.0
var freeze = false

var is_burning = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var initial_y = lv.y
	#if not is_jumping:
	#lv.y = 0.0
	#lv.x = 0.0
	#lv.y = 0.0
	var step = s.get_step()
	var found_floor = false
	var floor_object = null
	var floor_index = -1

	#get_angle_to(
	
	if not freeze:
		for x in range(s.get_contact_count()):
			var ci = s.get_contact_local_normal(x)
			var trans = s.get_transform()
			var rot = trans.get_rotation()
			var ci2 = ci.rotated(rot)
	
			#print("found contact")
			if (ci2.dot(Vector2(0, -1)) > 0.7):
				#print("found floor contact")
				if found_floor:
					pass
					#print("2nd contact", ci)
				found_floor = true
				floor_index = x
			
	if found_floor: # or (abs(lv.x) + abs(lv.y)) < 100.0:
		freeze = true
			
	if found_floor:
		# apply floor left/right push
		var floor_h_velocity = s.get_contact_collider_velocity_at_pos(floor_index).x
		lv.x += floor_h_velocity
		#lv.y += initial_y
		

	# apply gravity
	lv += s.get_total_gravity()*step
	
	
	
	# check freeze
	if freeze:
		lv.x = 0.0
		lv.y = 0.0
	
	s.set_linear_velocity(lv)
	
func _fixed_process(delta):
	
	if is_thrown:
		if not freeze:
			life -= delta
			if life <= 0:
				queue_free()
		else:
			#print ("frozen, end anim")
			
			spawn_oil()
		
			queue_free()
		
	
	
func spawn_oil():
	
	
				
	for oil_spot in get_node("oil_start").get_children():
		var oil = preload("res://oil_proj.tscn").instance()
		var start_pos = oil_spot.get_pos()
		start_pos = start_pos + get_pos()
		oil.set_pos(start_pos)
		
		var bottle_lin_vel = get_linear_velocity()
	
		bottle_lin_vel.x *= rand_range(0.05, 0.12)
		bottle_lin_vel.y *= rand_range(0.05, 0.12)
		
		oil.set_linear_velocity(bottle_lin_vel)
		get_parent().add_child(oil)
		
		if is_burning:
			oil.burn()
	
	

func throw():
	is_thrown = true
	
	set_linear_velocity(Vector2(x_velocity, y_velocity))


#func _on_bottle_body_enter( body ):
#	
#	# It hit something to interact with
#	if body extends StaticBody2D or body extends RigidBody2D:
#		#get_node("sprite").hide()
#		#get_node("dust").set_emitting(true)
#		#get_node("anim").play("explode")
#		
#		var scale = get_node("Sprite").get_scale()
#		scale.x = -scale.x
#		get_node("Sprite").set_scale(scale)
#		x_velocity = -x_velocity
		


func _on_bottle_body_enter( body ):
	
	# If hit
	if body extends StaticBody2D or body extends RigidBody2D:
		var lin_vel = get_linear_velocity()
		#print( lin_vel)
		if abs(lin_vel.x) + abs(lin_vel.y) < 10:
			#print("body enter slow freeze")
			freeze = true
			
		
	