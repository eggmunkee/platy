extends Area2D

export var can_pickup = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass



func _on_heart_item_body_enter( body ):
	if body extends preload("res://player.gd"):
		if not body.is_alive or can_pickup:
			body.pickup_heart()
		if can_pickup:
			queue_free()
