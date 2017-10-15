extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_base_body_enter( body ):
	
	if body extends preload("res://player.gd") and body.can_pickup_item():
		body.has_torch = true
		
		queue_free()
	elif body extends preload("res://oil_proj.gd") or body extends preload("res://crate.gd"):
		body.burn()
	elif body extends preload("res://bottle_proj.gd"):
		body.is_burning = true