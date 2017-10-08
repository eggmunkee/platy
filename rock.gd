extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var x_velocity = 300.0
export var y_velocity = -50.0
var life = 1.5

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	
	

func _fixed_process(delta):
	
	var pos = get_pos()
	pos.x += x_velocity * delta
	pos.y += y_velocity * delta
	set_pos(pos)
	
	life -= delta
	if life <= 0:
		get_parent().remove_child(self)
	
	if y_velocity < 500.0:
		y_velocity += 250.0 * delta
	
	