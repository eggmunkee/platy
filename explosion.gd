extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var life = 1.5

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


func _on_explosion_body_enter( body ):
	
	if body extends preload("res://oil_proj.gd") or body extends preload("res://crate.gd"):
		body.burn()
		
	