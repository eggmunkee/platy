extends StaticBody2D

var is_on = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func destroy(new_value):
	is_on = new_value
	
	if get_node("anim").is_playing():
		get_node("anim").stop_all()
	
	if is_on:
		get_node("anim").play("fadein")
	else:
		get_node("anim").play("fadeaway")
