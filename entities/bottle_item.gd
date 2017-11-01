extends "item_base.gd"

func _ready():
	
	set_fixed_process(true)
	
func _fixed_process(delta):
	
	var anim = get_node("anim")
	if time_since_fall < 0.5:
		if not anim.is_playing():
			anim.set_autoplay("moving")
			anim.play("moving")
	else:
		if anim.is_playing():
			anim.stop(true)

func on_player_overlap( body ):
	
	if body extends preload("res://player.gd") and body.can_pickup_item("bottle"):
		body.has_bottle = true
		
		queue_free()
