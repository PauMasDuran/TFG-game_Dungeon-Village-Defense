extends CharacterBody2D

@onready var player = get_parent().get_node("Player")


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		player.gotHitByPlayer()
