extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_spikes_body_enter( body ):
	
	if body extends preload("res://player.gd"):
		body.kill()
