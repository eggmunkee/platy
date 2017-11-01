extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var x_velocity = 300.0
export var y_velocity = -50.0
var life = 1.5
var freeze = false


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
	#get_node(
	

func _fixed_process(delta):
	
	if not freeze:
		var pos = get_pos()
		pos.x += x_velocity * delta
		pos.y += y_velocity * delta
		set_pos(pos)
		
		life -= delta
		if life <= 0:
			get_parent().remove_child(self)
	
		if y_velocity < 500.0:
			y_velocity += 150.0 * delta
	
	

func _on_rock_body_enter( body ):
	
	if body extends StaticBody2D or body extends RigidBody2D and not body extends preload("res://entities/oil_proj.gd"):
		#get_node("sprite").hide()
		#get_node("dust").set_emitting(true)
		get_node("anim").play("explode")
		
		if body extends RigidBody2D:
			var mass = body.get_mass()
			var push_velocity = Vector2(x_velocity * 2000.0 / mass, y_velocity * 2000.0 / mass)
			body.apply_impulse(Vector2(0.0,0.0), push_velocity)
		
		if body extends preload("res://entities/crate.gd") or body extends preload("res://entities/static_crate.gd"):
			body.damage(10.0)
	
	
		x_velocity = 0.0
		y_velocity = 0.0
		life = 0.0
		freeze = true
	
	if body extends preload("res://entities/switch_area.gd"):
		body.toggle_switch()
		
