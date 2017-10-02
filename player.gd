extends RigidBody2D

const jump_timer_default = 2.5
const walk_frame_rate = 7.0

var gravity_ratio = 1.0

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_jumping = false
var is_falling = false
var jump_timer = 0.0
var jump_rate = 35000.0
#var jump_impulse = 50.0
var max_fall = 8.0
var base_move_speed = 12000.0
var timer_increment = 0.8
var was_jump_held = false
var total_jump_length = 0.0
var min_jump_length = 15.0
var lock_jump_x = 0.0
#var floor_h_velocity = 0.0
var is_facing_right = true
var cam_scale = 0.85
var cam_pause = 0.0

var frame_name = 'base'
var frame_timer = 0.0
var arms_frame_name = 'base'
var arms_frame_timer = 0.0

var is_alive = true

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var initial_y = lv.y
	#if not is_jumping:
	#lv.y = 0.0
	lv.x = 0.0
	lv.y = 0.0
	var step = s.get_step()
	var found_floor = false
	var floor_object = null
	var floor_index = -1
	
	var eff_jump_rate = jump_rate / gravity_ratio
	var eff_jump_timer_default = jump_timer_default * gravity_ratio
		
	#lv.x -= floor_h_velocity
	#floor_h_velocity = 0.0
	#print("integrate forces - initial y = " + str(initial_y))
	
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		#print("found contact")
		if (ci.dot(Vector2(0, -1)) > 0.6):
			if found_floor:
				pass
				#print("2nd contact", ci)
			found_floor = true
			floor_index = x
#			

	# check input/keyboard state
	var walk_left = Input.is_action_pressed("ui_left")
	var walk_right = Input.is_action_pressed("ui_right")
	var walk_up = Input.is_action_pressed("ui_up")
	var walk_down = Input.is_action_pressed("ui_down")
	var jump = Input.is_action_pressed("jump")
	var shoot = Input.is_action_pressed("shoot")
	
	# Handle left/right movement and frame management
	if walk_left or walk_right:
		if walk_left:
			lv.x += step * (-1.0 * self.base_move_speed)
			if is_facing_right:
				is_facing_right = false
				var scale = get_node("body").get_scale()
				scale.x = -1.0 * abs(scale.x)
				get_node("body").set_scale(scale)
				scale = get_node("arms").get_scale()
				scale.x = -1.0 * abs(scale.x)
				get_node("arms").set_scale(scale)
				if not (is_falling or is_jumping):
					get_node("foot_dust").set_emitting(true)
		if walk_right:
			lv.x += step * (self.base_move_speed)
			if not is_facing_right:
				is_facing_right = true
				var scale = get_node("body").get_scale()
				scale.x = 1.0 * abs(scale.x)
				get_node("body").set_scale(scale)
				scale = get_node("arms").get_scale()
				scale.x = 1.0 * abs(scale.x)
				get_node("arms").set_scale(scale)
				if not (is_falling or is_jumping):
					get_node("foot_dust").set_emitting(true)
		
				
		if not is_jumping and not is_falling:
			frame_timer += step * walk_frame_rate
			arms_frame_timer += step * walk_frame_rate * 0.67
			if frame_timer > 1.0:
				frame_timer -= 1.0
				if frame_name == 'base':
					get_node("foot_dust").set_emitting(true)
					frame_name = 'walk'
				else:
					frame_name = 'base'
			if arms_frame_timer > 1.0:
				arms_frame_timer -= 1.0
				if arms_frame_name == 'base':
					arms_frame_name = 'walk'
				else:
					arms_frame_name = 'base'
		elif is_jumping:
			frame_name = 'jump'
			arms_frame_name = 'attack'
		elif is_falling: # and jump_timer < eff_jump_timer_default * 0.5:
			frame_name = 'fall'
			arms_frame_name = 'attack'
		else:
			frame_name = 'base'
			arms_frame_name = 'base'
			
	else:
		lv.x = 0.0
		if not is_jumping and (not is_falling): # or jump_timer > eff_jump_timer_default * 0.5):
			if not (frame_name == "walk" or frame_name == "base"):
				frame_name = 'base'
				arms_frame_name = 'base'
		elif is_falling:  #and jump_timer <= eff_jump_timer_default * 0.5:
			frame_name = 'fall'
			arms_frame_name = 'walk'
		else:
			frame_name = 'jump'
			arms_frame_name = 'attack'
		
	# Check for start jump
	if not is_jumping and not is_falling:
		if not was_jump_held and (walk_up or jump):
			init_jump(eff_jump_timer_default)
			get_node("foot_dust").set_emitting(true)
			
		elif not found_floor:
			jump_timer = 0.0
			init_fall()
			
	# Handle already jumping
	elif is_jumping:
		jump_timer -= 0.1
		total_jump_length += 0.1
				
		if jump_timer > eff_jump_timer_default * 0.3:
			lv.y -= step * (1.0 * eff_jump_rate)
		elif jump_timer > eff_jump_timer_default * 0.5:
			lv.y -= step * (0.8 * eff_jump_rate)
		elif jump_timer > eff_jump_timer_default * 0.7:
			lv.y -= step * (0.5 * eff_jump_rate)
		elif jump_timer > eff_jump_timer_default * 0.9:
			lv.y -= step * (0.3 * eff_jump_rate)
		elif jump_timer <= 0.0:
			init_fall()
		
		if jump_timer < eff_jump_timer_default * 0.7 and not (walk_up or jump):
			init_fall()
#	
	# Handle falling state
	elif is_falling:
		jump_timer += 0.1
		
		
		if jump_timer > eff_jump_timer_default * 0.25 and jump_timer < 3.0 and not was_jump_held and (walk_up or jump):
			init_jump(eff_jump_timer_default * 1.25)
		else:
			if jump_timer > eff_jump_timer_default * 0.3:
				lv.y += step * (1.0 * eff_jump_rate)
			elif jump_timer > 0.0:
				lv.y += step * (0.7 * eff_jump_rate)

		if found_floor:
			stop_fall()
			get_node("foot_dust").set_emitting(true)
			lv.y = initial_y
	
	# Save previously holding jump state
	was_jump_held = (walk_up or jump)
	
	# Handle camera scaling based on movement/jumping state if it were enabled 
#	var cam_scale_step = 0.001
#	if cam_pause > 0.0:
#		cam_pause -= 0.1
#	else:
#		if found_floor: # and not (walk_left or walk_right):
#			var ground_zoom = 0.98
#			if cam_scale > ground_zoom:
#				cam_scale -= cam_scale_step
#				if cam_scale < ground_zoom:
#					cam_scale = ground_zoom
#			elif cam_scale < ground_zoom:
#				cam_scale += cam_scale_step
#				if cam_scale > ground_zoom:
#					cam_scale = ground_zoom
#			else:
#				cam_pause = 20.0
#		else:
#			var hopping_zoom = 1.02
#			if cam_scale > hopping_zoom:
#				cam_scale -= cam_scale_step
#				if cam_scale < hopping_zoom:
#					cam_scale = hopping_zoom
#			elif cam_scale < hopping_zoom:
#				cam_scale += cam_scale_step
#				if cam_scale > hopping_zoom:
#					cam_scale = hopping_zoom
#			else:
#				cam_pause = 5.5
		
	get_node("player_cam").set_zoom(Vector2(cam_scale, cam_scale))

	# Update player frame
	update_frame()
		
	#floor_h_velocity = s.get_contact_collider_velocity_at_pos(floor_index).x
	#lv.x += floor_h_velocity
		#lv.y += initial_y
		

#	lv += s.get_total_gravity()*step
	s.set_linear_velocity(lv)

func update_frame():
	# Handle showing player frame
	var body = get_node("body")
	for frame in body.get_children():
		if frame.get_name() == "body_" + frame_name:
			frame.show()
		else:
			frame.hide()
			
	var arms = get_node("arms")
	for frame in arms.get_children():
		if frame.get_name() == "arms_" + arms_frame_name:
			frame.show()
		else:
			frame.hide()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
	get_node("player_cam").make_current()
	get_node("player_cam").set_scale(Vector2(cam_scale, cam_scale))
	
func init_jump(jump_timer_length):
	is_jumping = true
	is_falling = false
	jump_timer = jump_timer_length
	#self.jump_rate = 200.0
	#self.jump_rate = 8.0
	total_jump_length = 0.0
	#self.lock_jump_x = 0.0

func init_fall():
	is_jumping = false
	is_falling = true
	#self.jump_timer = self.timer_increment
	#self.jump_rate = self.jump_rate
	
func stop_fall():
	is_falling = false
	
	#self.jump_timer = 0.0

func _fixed_process(delta):
	pass
	
	
	
	