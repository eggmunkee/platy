extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var is_burning = false
var life = 50

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
func fixed_process(delta):
	pass
	#var rot = get_rot()
	#get_node("torch").set_rot(-1.0 * rot)
	

func damage(amount):
	
	
	if not is_burning:
		life -= amount
		
		if life <= 0:
			is_burning = true
			get_node("anim").play("explode")


func burn():

	if not is_burning:
		is_burning = true
		get_node("anim").play("burn")
		
