extends RigidBody2D

const jump_timer_default = 2.5 #3.2   #2.5
const walk_frame_rate = 8.0
const throw_anim_length = 0.22  #0.4

var gravity_ratio = 1.0
var max_fall_length = 15.0

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_jumping = false
var is_falling = false
var jump_timer = 0.0
var jump_rate = 35000.0 # 22000.0   # 35000.0
var jump_count = 0
var max_jump_count = 1
#var jump_impulse = 50.0
var max_fall = 8.0
var base_move_speed = 18000.0
var slow_walk_ratio = 0.5
var timer_increment = 0.8

var total_jump_length = 0.0
var min_jump_length = 15.0
var lock_jump_x = 0.0
#var floor_h_velocity = 0.0
var is_facing_right = true
var cam_scale = 0.75
var cam_pause = 0.0

var floor_timer = 0.0
var ghost_floor_time = 0.1
var run_timer = 0.0

var frame_name = 'base'
var frame_timer = 0.0
var arms_frame_name = 'base'
var arms_frame_timer = 0.0

var is_alive = true
var kill_timer = 5.0
var kill_flash = 0.0

var is_god = false

var grav_timer = 0.0

# item flags
export var has_rocks = false
export var has_torch = false
export var has_bottle = false
export var num_hearts = 0


# key flags
# Init all to true to avoid any initally held key acting
var was_jump_held = true
var was_shoot_held = true
var was_up_grav_down = true
var was_throw_held = true
var was_kill_held = true
var was_god_held = true
var was_respawn = false

func respawn():
	has_rocks = false
	has_bottle = false
	has_torch = false
	is_alive = true
	kill_timer = 5.0
	jump_timer = 0.0
	set_mode(MODE_CHARACTER)
	set_rot(0.0)
	set_angular_velocity(0.0)
	set_linear_velocity(Vector2(0.0,0.0))
	was_respawn = true
	get_node("/root/world").update_dying(false, 0.0)
	

func _integrate_forces(s):

	var lv = s.get_linear_velocity()
	var initial_y = lv.y
	
	var phys_rotation = s.get_transform().get_rotation()
	var is_tilted = abs(phys_rotation) > 0.7
	
	if is_alive and abs(get_rot()) > 0.1:
		var curr_loc = s.get_transform().get_origin()
		s.set_transform(Matrix32(0.0, curr_loc))
		s.set_angular_velocity(0.0)
		s.set_linear_velocity(Vector2(0.0, 0.0))
		lv = Vector2(0.0,0.0)
		initial_y = lv.y
		was_respawn = false

	#if not is_jumping:
	#lv.y = 0.0
	lv.x = 0.0
	lv.y = 0.0
	var step = s.get_step()
	var found_floor = false
	var floor_object = null
	var floor_index = -1
	
	var hit_head = false
	
	if floor_timer > 0.0:
		floor_timer -= step
	
		
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
			floor_timer = ghost_floor_time
#			
		#elif (ci.dot(Vector2(0,1)) > 0.7):
		#	call_deferred("kill")

	# check input/keyboard state
	var walk_left = Input.is_action_pressed("ui_left")
	var walk_right = Input.is_action_pressed("ui_right")
	var walk_up = Input.is_action_pressed("ui_up")
	var walk_down = Input.is_action_pressed("ui_down")
	var jump = walk_up or Input.is_action_pressed("jump")
	var shoot = Input.is_action_pressed("attack")
	var throw = Input.is_action_pressed("throw")
	var increase_grav = Input.is_action_pressed("up_grav")
	var do_throw = throw and not was_throw_held
	var kill = Input.is_action_pressed("suicide")
	var god_pr = Input.is_action_pressed("god")
	var do_god = not was_god_held and god_pr
	
	var zoom_up = Input.is_action_pressed("zoom_up")
	var zoom_down = Input.is_action_pressed("zoom_down")
	
	if zoom_down and cam_scale < 1.5:
		cam_scale += 0.5 * step
		if cam_scale > 1.5:
			cam_scale = 1.5
	elif zoom_up and cam_scale > 0.3:
		cam_scale -= 0.5 * step
		if cam_scale < 0.3:
			cam_scale = 0.3
		

	
	if not is_alive:
		if kill_timer < 3.1:
			jump = false
		if kill_timer < 1.8:
			walk_left = false
			walk_right = false
		walk_up = false
		walk_down = false
		shoot = false
		throw = false
		
		if is_facing_right:
			if phys_rotation > -1.5 and phys_rotation < 1.5:
				s.set_angular_velocity(rand_range(1.0,6.0))
		else:
			if phys_rotation < 1.5 and phys_rotation > -1.5:
				s.set_angular_velocity(rand_range(-6.0,-1.0))

	if not was_kill_held and kill:
		if is_alive:
			kill()
		else:
			kill_timer = 0.0
			
	if do_god:
		is_god = not is_god

	if increase_grav and not was_up_grav_down:
		gravity_ratio *= 1.50
		grav_timer += 10.0
		
	var space_time = get_node("space_time")
	if grav_timer > 0.0:
		grav_timer -= 0.001
		
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
	var eff_move_speed = base_move_speed
	var eff_slow_walk_speed = slow_walk_ratio * eff_move_speed
	
	if not is_alive:
		eff_jump_timer_default *= 0.5
	
	if has_rocks:
		eff_jump_timer_default *= 0.75
	if has_rocks and arms_frame_timer <= 0.0:
		#eff_move_speed *= 0.85
		get_node("arms/rocks").show()
	else:
		get_node("arms/rocks").hide()
	
	if has_torch and (not has_bottle or arms_frame_timer <= 0.0):
		get_node("arms/torch").show()
	else:
		get_node("arms/torch").hide()

	if has_bottle:
		eff_jump_timer_default *= 0.75
	if has_bottle and arms_frame_timer <= 0.0:
		get_node("arms/bottle").show()
	else:
		get_node("arms/bottle").hide()
		
	var punch_forward = false
	var pull_back = false
		
	# Handle attacks
	# Did just attack?
	if arms_frame_timer > 0.0:
		if arms_frame_timer > throw_anim_length / 2.0:
			arms_frame_name = 'attack'
		elif arms_frame_name != 'base':
			if not is_holding_item():
				pull_back = true
			arms_frame_name = 'base'
	
		arms_frame_timer -= step
		
		
	else:
		# Start attack?
		if has_rocks and shoot: # and not was_shoot_held:
			var rock = preload("res://entities/rock.tscn").instance()
	
			# Get position to create rock instance
			var pos = get_node("throw_origin").get_pos()
			# x-flip if facing left
			if get_node("arms").get_scale().x < 0:
				pos.x = -pos.x
				rock.x_velocity = -1.0 * rock.x_velocity
				if walk_left:
					rock.x_velocity -= 120.0
			else:
				if walk_right:
					rock.x_velocity += 120.0
					
			rock.x_velocity += rand_range(-10.0, 10.0)
			rock.y_velocity += rand_range(-10.0, 10.0)
				
			# set rock position including player position
			rock.set_pos(pos + get_pos())
			# add rock to parent scene (the stage)
			get_parent().add_child(rock)
			arms_frame_name = 'attack'
			arms_frame_timer = throw_anim_length
			
		elif has_bottle and shoot:
			var bottle = preload("res://entities/bottle_proj.tscn").instance()
	
			# Get position to create rock instance
			var pos = get_node("throw_origin").get_pos()
			# x-flip if facing left
			if get_node("arms").get_scale().x < 0:
				pos.x = -pos.x
				bottle.x_velocity = -1.0 * bottle.x_velocity
				if walk_left:
					bottle.x_velocity -= 180.0
			else:
				if walk_right:
					bottle.x_velocity += 180.0
					
			bottle.x_velocity += rand_range(-10.0, 10.0)
			bottle.y_velocity += rand_range(-10.0, 10.0)
				
			# set rock position including player position
			bottle.set_pos(pos + get_pos())
			bottle.throw()
			
			if has_torch:
				bottle.is_burning = true
			# add rock to parent scene (the stage)
			get_parent().add_child(bottle)
			arms_frame_name = 'attack'
			arms_frame_timer = throw_anim_length * 2.0
		#elif has_torch and shoot:
		#	arms_frame_name = 'attack'
		elif not is_holding_item() and shoot:
			arms_frame_name = 'attack'
			punch_forward = true
			
			do_punch()
			
		else:
			arms_frame_name = 'base'
		
	# Handle throw action
	if has_rocks and do_throw:
		drop_rocks()
		
	elif has_torch and do_throw:
		drop_torch()
		
	elif has_bottle and do_throw:
		drop_bottle()
	
	# Handle left/right movement and frame management
	if walk_left or walk_right:
		run_timer += step

		# Adjust rotation walk wiggle and dying (crawl + flipping while crawling)
		var curr_rot = get_rot()
		if not is_jumping and not is_falling:
			var wiggle_amount = 0.08
			if not is_alive:
				wiggle_amount = 0.15
			var wiggle_tilt = sin(run_timer * 22.0) * wiggle_amount
			if not is_facing_right:
				wiggle_tilt *= -1.0
			curr_rot += wiggle_tilt
		if not is_alive and found_floor:
			if curr_rot < -0.7 and curr_rot > -2.2 and walk_left:
				curr_rot += PI
			elif curr_rot > 0.7 and curr_rot < 2.2 and walk_right:
				curr_rot -= PI
		set_rot(curr_rot)
		
		if run_timer < 0.5:
			var speed_diff = eff_move_speed - eff_slow_walk_speed
			eff_move_speed = eff_slow_walk_speed + speed_diff * (run_timer / 0.5)
			
		if not is_alive:
			eff_move_speed *= 0.5
		
		if walk_left: # and not is_tilted:
			lv.x += step * (-1.0 * eff_move_speed)
			lv.y -= step * (0.5)
			if is_facing_right: # and is_alive:
				is_facing_right = false
				var scale = get_node("body").get_scale()
				scale.x = -1.0 * abs(scale.x)
				get_node("body").set_scale(scale)
				scale = get_node("arms").get_scale()
				scale.x = -1.0 * abs(scale.x)
				get_node("arms").set_scale(scale)
				if not (is_falling or is_jumping):
					get_node("foot_dust").set_emitting(true)
		if walk_right: # and not is_tilted:
			lv.x += step * (eff_move_speed)
			lv.y -= step * (0.5)
			if not is_facing_right: # and is_alive:
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
			run_timer = 0.0
			if not (frame_name == "walk" or frame_name == "base"):
				frame_name = 'base'
		elif is_falling:  #and jump_timer <= eff_jump_timer_default * 0.5:
			frame_name = 'fall'
		else:
			frame_name = 'jump'
		
	# Check for start jump
	if (not is_jumping and not is_falling) or (is_god and not was_jump_held and jump):
		if not was_jump_held and jump:
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
		
		if jump_timer < eff_jump_timer_default * 0.7 and not jump:
			init_fall()
#	
	# Handle falling state
	elif is_falling:
		jump_timer += 0.1
		
		if floor_timer > 0.0 and not was_jump_held and jump:
			jump_count = 0
			floor_timer = 0.0
			init_jump(eff_jump_timer_default)
			get_node("foot_dust").set_emitting(true)
		
		elif jump_count < max_jump_count and jump_timer > eff_jump_timer_default * 0.25 and jump_timer < 3.0 and not was_jump_held and jump:
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
	was_jump_held = jump
	was_up_grav_down = increase_grav
	was_shoot_held = shoot
	was_throw_held = throw
	was_god_held = god_pr
	was_kill_held = kill
	
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
	#get_node("player_cam/ui").set_scale(Vector2(cam_scale, cam_scale))

	# Update player frame
	update_frame()
		
	if found_floor:
		var floor_h_velocity = s.get_contact_collider_velocity_at_pos(floor_index).x
		lv.x += floor_h_velocity
		#lv.y += initial_y
		#lv.y += 15.0
		

#	lv += s.get_total_gravity()*step
	s.set_linear_velocity(lv)

func is_holding_item():
	return has_torch or has_bottle or has_rocks

func do_punch():
	var punch_origin_node = get_node('throw_origin')
	var punch_pos = get_pos() + punch_origin_node.get_pos()
	var punch_dir = Vector2(1.0, 0.0)
	
	if not is_facing_right:
		punch_dir.x = -punch_dir.x
	
	var physics2d_state = get_viewport().get_world_2d().get_direct_space_state()
	var res = physics2d_state.intersect_ray(punch_pos, punch_dir, [self])
	
	print(res)
	
	

func drop_rocks():
	if has_rocks:
		has_rocks = false
		var rocks_item = preload("res://entities/rocks_item.tscn").instance()
		rocks_item.toss(is_facing_right)
		var pos = get_node("throw_origin").get_pos()
		if not is_facing_right:
			pos.x = -1.0 * pos.x
		pos = pos + get_pos()
		rocks_item.set_pos(pos)
		get_parent().add_child(rocks_item)

func drop_bottle():
	if has_bottle:
		has_bottle = false
		var bottle_item = preload("res://entities/bottle_item.tscn").instance()
		bottle_item.toss(is_facing_right)
		var pos = get_node("throw_origin").get_pos()
		if not is_facing_right:
			pos.x = -1.0 * pos.x
		pos = pos + get_pos()
		bottle_item.set_pos(pos)
		get_parent().add_child(bottle_item)
		
func drop_torch():
	if has_torch:
		has_torch = false
		var torch_item = preload("res://entities/torch_item.tscn").instance()
		
		var pos = null
		if has_bottle:
			pos = get_node("drop_position").get_pos()
		else:
			pos = get_node("throw_origin").get_pos()
			torch_item.toss(is_facing_right)
		if not is_facing_right:
			pos.x = -1.0 * pos.x
		pos = pos + get_pos()
		torch_item.set_pos(pos)
		get_parent().add_child(torch_item)

func pickup_heart():
	if is_alive:
		if num_hearts < 3:
			num_hearts += 1
			update_hearts()
	
	else:
		call_deferred("_pickup_heart")
		
func update_hearts():
	get_node("/root/world/").update_hearts(num_hearts)
		
func _pickup_heart():
	if not is_alive:
		respawn()
		

func kill():
	if not is_god:
		call_deferred("_kill")
	
func _kill():
	
	if is_alive:
		is_alive = false
		set_mode(MODE_RIGID)
		#set_use_custom_integrator(false)
		
		#apply_impulse(Vector2(0.0,0.0), Vector2(rand_range(-15000.0,15000.0),rand_range(-500.0,500.0)))
		
		#drop_torch() # keep the torch for fun
		drop_rocks()
		drop_bottle()
		

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
	
	#get_node("player_cam").make_current()
	get_node("player_cam").set_scale(Vector2(cam_scale, cam_scale))
	
	get_node("/root/world").update_dying(false, 0.0)
	
	# set ui hearts to current amount
	update_hearts()

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
	
	
	if jump_timer > max_fall_length:
		kill()
	
	if is_alive:
		get_node("blood_effect").set_emitting(false)
		get_node("body").show()
		get_node("arms").show()
	else:
		kill_timer -= delta
		kill_flash -= delta
		var rot = get_rot()
	
		get_node("blood_effect").set_rot(-rot)
		
		if kill_timer > 1.5:
			get_node("blood_effect").set_emitting(true)
		else:
			get_node("blood_effect").set_emitting(false)
			
		# update global bw filter
		var filter_opacity = 1.0 - (0.8 * min(5.0, kill_timer) / 5.0)
		get_node("/root/world").update_dying(true, filter_opacity)
		
		if kill_timer < 4.5:
			
			if kill_timer < 3.5 and num_hearts > 0:
				num_hearts -= 1
				update_hearts()
				respawn()
				return
		
			if kill_flash < 0.0:
				kill_flash = 0.15
			elif kill_flash < 0.08:
				get_node("body").show()
				get_node("arms").show()
			else:
				get_node("body").hide()
				get_node("arms").hide()
		
		if kill_timer < 0.0:
			get_node("/root/world").call_deferred("restart_level")
	
func can_pickup_item(new_item):
	
	# special case with torch + bottle
	if new_item == "torch" and has_bottle and not has_torch:
		return true
		
	if not is_alive:
		return false
	
	if new_item == "bottle" and has_torch and not has_bottle:
		return true
	
	# otherwise, if have no items
	return not is_holding_item()


func _on_Area2D_body_enter( body ):
	
	if has_torch and body extends preload("res://entities/crate.gd"):
		body.burn()
		
	if has_torch and body extends preload("res://entities/oil_proj.gd"):
		body.burn()
		
	

