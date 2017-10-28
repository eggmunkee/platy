extends "item_base.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func on_player_overlap(player):
	
	if player extends preload("res://player.gd") and player.can_pickup_item("rock"):
		player.has_rocks = true
		
		queue_free()
