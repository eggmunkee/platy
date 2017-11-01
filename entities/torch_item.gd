extends "item_base.gd"

export var is_on = true


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	
	if is_on:
		show()
	else:
		hide()

func input_value(new_value):
	is_on = new_value
	
	if is_on:
		show()
	else:
		hide()


func on_player_overlap( body ):
	
	if is_on:
		if body extends preload("res://player.gd") and body.can_pickup_item("torch"):
			body.has_torch = true
			
			queue_free()
			
func on_body_overlap( body ):
	if is_on:
		if body extends preload("res://entities/oil_proj.gd") or body extends preload("res://entities/crate.gd"):
			body.burn()
		elif body extends preload("res://entities/bottle_proj.gd"):
			body.is_burning = true
#
#func _on_base_body_enter( body ):
#	
#	if is_on:
#		if body extends preload("res://player.gd") and body.can_pickup_item("torch"):
#			body.has_torch = true
#			
#			queue_free()
#		elif body extends preload("res://oil_proj.gd") or body extends preload("res://crate.gd"):
#			body.burn()
#		elif body extends preload("res://bottle_proj.gd"):
#			body.is_burning = true
