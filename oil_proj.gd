extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var life = 20.0
var is_burning = false


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)

func _fixed_process(delta):
	
	if life > 0:
		life -= delta
		
		if life < 1.5:
			set_opacity(life / 1.5)
	else:
		queue_free()

	# Keep certain items vertically aligned
	var rot = get_rot()
	get_node("Sprite").set_rot(-rot)
	if is_burning:
		get_node("flame").set_rot(-rot)
	
	if is_burning and life < 4.8 and life > 0.3:
		var colliders = get_colliding_bodies()
		
		for body in colliders:
			if body extends get_script() or body extends preload("res://crate.gd") or body extends preload("res://static_crate.gd"):
				body.burn()
	
func burn():
	if not is_burning:
		get_node("flame").show()
		get_node("fire_shape").show()
		life = 5.0
		is_burning = true
		set_linear_damp(0.25)

func _on_oil_proj_body_enter( body ):
	pass
