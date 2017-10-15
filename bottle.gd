extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_thrown = false
var x_velocity = 300.0
var y_velocity = 25.0
var life = 1.5
var freeze = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	if is_thrown and not freeze:
		
		var pos = get_pos()
		pos.x += x_velocity * delta
		pos.y += y_velocity * delta
		set_pos(pos)
		
		life -= delta
		if life <= 0:
			queue_free()
	
		if y_velocity < 500.0:
			y_velocity += 150.0 * delta
		
		

func throw():
	is_thrown = true


func _on_bottle_body_enter( body ):
	
	# It hit something to interact with
	if body extends StaticBody2D or body extends RigidBody2D:
		#get_node("sprite").hide()
		#get_node("dust").set_emitting(true)
		#get_node("anim").play("explode")
		
		var scale = get_node("Sprite").get_scale()
		scale.x = -scale.x
		get_node("Sprite").set_scale(scale)
		x_velocity = -x_velocity
		
