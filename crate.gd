extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_exploding = false
var is_burning = false
var life = 50
var burn_time = 0.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	var rot = get_rot()
	
	get_node("torch").set_rot(-rot)
	
	
	if is_burning:
		burn_time -= delta
		
		if burn_time < 0.25:
			var colliders = get_colliding_bodies()
			
			for body in colliders:
				if body extends get_script() or body extends preload("res://oil_proj.gd"):
					body.burn()
				elif body extends preload("res://bottle_proj.gd"):
					body.freeze = true
	

func damage(amount):
	
	
	if not is_exploding:
		life -= amount
		
		if life <= 0:
			is_exploding = true
			get_node("anim").play("explode")


func burn():

	if not is_burning:
		is_burning = true
		get_node("anim").play("burn")
		burn_time = 1.5
		
