extends StaticBody2D

export var is_open = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	pass

func set_closed(open):
	set_open(not open)
	
func set_open(open):
	if is_open != open:
		
		is_open = open
		
		if is_open:
			get_node("sprite").set_frame(1)
			get_node("collision").set_trigger(true)
		else:
			get_node("sprite").set_frame(0)
			get_node("collision").set_trigger(false)
