extends "item_base.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func on_player_overlap( body ):
	
	if body extends preload("res://player.gd") and body.can_pickup_item("bottle"):
		body.has_bottle = true
		
		queue_free()
