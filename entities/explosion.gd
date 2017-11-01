extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var life = 1.5

var affected_objects = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	life -= delta
	
	if life < 0.5:
		get_node("oil_particles").set_emitting(false)
		
	if life < 0.0:
		get_node("fire").set_emitting(false)
		get_node("smoke").set_emitting(false)
		
	if life < -1.5:
		queue_free()
		

		
	for body in affected_objects:
		
		var is_pushable = body extends RigidBody2D and not body extends preload("res://entities/oil_proj.gd")
		var is_burnable = body extends preload("res://entities/oil_proj.gd") or body extends preload("res://entities/crate.gd") or body extends preload("res://entities/bottle_proj.gd")
		var is_player = body extends preload("res://player.gd")
		
		if life < 0.0:
			is_burnable = false
		
		if is_pushable or is_burnable:
			
			var body_pos = body.get_pos()
			var my_pos = get_pos()
			var diff = body_pos - my_pos
			var dist = sqrt(pow(diff.x, 2.0) + pow(diff.y,2.0))
			
			# ONly burn a closer distance
			if is_burnable and dist < 35.0 and life > 0.0:
				body.burn()
			if dist < 45.0 and life > 0.2 and is_player:
				body.kill()
			
			var max_dist = 50.0
			
			diff *= max(0.0, (max_dist - dist) / max_dist) * 50000.0 * delta
			
			#if life < 1.0:
			diff *= max(0.0, life)
			
			if is_player:
				diff *= 0.5
				
			
			if life < 0.0:
				is_pushable = false
			
			if is_pushable:
				body.apply_impulse(Vector2(0.0,0.0), Vector2(diff) )
		
		


func _on_explosion_body_enter( body ):
	
	affected_objects.append(body)
	
	
func _on_explosion_body_exit( body ):
	
	var index = affected_objects.find(body)
	if index >= 0:
		affected_objects.remove(index)

	
#	var is_pushable = body extends RigidBody2D and not body extends preload("res://oil_proj.gd")
#	
#	var is_burnable = body extends preload("res://oil_proj.gd") or body extends preload("res://crate.gd") or body extends preload("res://bottle_proj.gd")
#	
#	if is_pushable or is_burnable:
#		
#		var body_pos = body.get_pos()
#		var my_pos = get_pos()
#		var diff = body_pos - my_pos
#		var dist = sqrt(pow(diff.x, 2.0) + pow(diff.y,2.0))
#		
#		# ONly burn a closer distance
#		if is_burnable and dist < 20.0:
#			body.burn()
#		
#		diff *= max(0.1, (50.0 - dist)) * 150.0
#		#print (diff)
#		
#		if is_pushable:
#			body.apply_impulse(Vector2(0.0,0.0), Vector2(diff) )
		
	

