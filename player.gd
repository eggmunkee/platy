extends RigidBody2D

const jump_timer_default = 2.5
const walk_frame_rate = 7.0
const throw_anim_length = 0.4

var gravity_ratio = 1.0

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_jumping = false
var is_falling = false
var jump_timer = 0.0
var jump_rate = 35000.0
var jump_count = 0
var max_jump_count = 2
#var jump_impulse = 50.0
var max_fall = 8.0
var base_move_speed = 12000.0
var timer_increment = 0.8

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

var grav_timer = 0.0

# key flags
var was_jump_held = false
var was_shoot_held = false
var was_up_grav_down = false

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
	var shoot = Input.is_action_pressed("attack")
	var increase_grav = Input.is_action_pressed("up_grav")

	
	if increase_grav and not was_up_grav_down:
		gravity_ratio *= 1.50
		grav_timer += 10.0
		
	var space_time = get_node("space_time")
	if grav_timer > 0.0:
		grav_timer -= 0.1
		
		if grav_timer <= 0.0:
			grav_timer = 0.0
			gravity_ratio = 1.0
			
		space_time.show()
		space_time.set_value(min(10.0, grav_timer) / 10.0 * 100.0)
		
	else:
		space_time.hide()
	
	
	var eff_jump_rate = jump_rate
	var eff_fall_rate = jump_rate / gravity_ratio
	var eff_jump_timer_default = jump_timer_default * gravity_ratio
	
	
	# Handle attacks
	# Did just attack?
	if arms_frame_timer > 0.0:
		if arms_frame_timer > throw_anim_length / 2.0:
			arms_frame_name = 'attack'
		else:
			arms_frame_name = 'base'
	
		arms_frame_timer -= step
		
		
	else:
		# Start attack?
		if shoot: # and not was_shoot_held:
			var rock = preload("res://rock.tscn").instance()
	
			# Get position to create rock instance
			var pos = get_node("arms/throw_origin").get_pos()
			# x-flip if facing left
			if get_node("arms").get_scale().x < 0:
				pos.x = -pos.x
				rock.x_velocity = -1.0 * rock.x_velocity
				if walk_left:
					rock.x_velocity -= 120.0
			else:
				if walk_right:
					rock.x_velocity += 120.0
				
			# set rock position including player position
			rock.set_pos(pos + get_pos())
			# add rock to parent scene (the stage)
			get_parent().add_child(rock)
			arms_frame_name = 'attack'
			arms_frame_timer = throw_anim_length
			
		else:
			arms_frame_name = 'walk'
		
	
	
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
			
			if frame_timer > 1.0:
				frame_timer -= 1.0
				if frame_name == 'base':
					get_node("foot_dust").set_emitting(true)
					frame_name = 'walk'
				else:
					frame_name = 'base'
		elif is_jumping:
			frame_name = 'jump'
		elif is_falling: # and jump_timer < eff_jump_timer_default * 0.5:
			frame_name = 'fall'
		else:
			frame_name = 'base'
			
	else:
		lv.x = 0.0
		if not is_jumping and (not is_falling): # or jump_timer > eff_jump_timer_default * 0.5):
			if not (frame_name == "walk" or frame_name == "base"):
				frame_name = 'base'
		elif is_falling:  #and jump_timer <= eff_jump_timer_default * 0.5:
			frame_name = 'fall'
		else:
			frame_name = 'jump'
		
	# Check for start jump
	if not is_jumping and not is_falling:
		if not was_jump_held and (walk_up or jump):
			jump_count = 0
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
		
		
		if jump_count < max_jump_count and jump_timer > eff_jump_timer_default * 0.25 and jump_timer < 3.0 and not was_jump_held and (walk_up or jump):
			init_jump(eff_jump_timer_default * 1.25)
		else:
			if jump_timer > eff_jump_timer_default * 0.3:
				lv.y += step * (1.0 * eff_fall_rate)
			elif jump_timer > 0.0:
				lv.y += step * (0.7 * eff_fall_rate)

		if found_floor:
			stop_fall()
			get_node("foot_dust").set_emitting(true)
			lv.y = initial_y
	
	# Save previously holding jump state
	was_jump_held = (walk_up or jump)
	was_up_grav_down = increase_grav
	was_shoot_held = shoot
	
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
		elif frame.get_name().substr(0, 5) == "arms_":
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
	total_jump_length = 0.0
	#self.lock_jump_x = 0.0
	jump_count += 1

func init_fall():
	is_jumping = false
	is_falling = true
	
func stop_fall():
	is_falling = false

func _fixed_process(delta):
	pass
	
	
	
	