extends Node2D

@onready var animated_sprite = $Sprite2D/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite.play("scaling_up")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "scaling_up":
		animated_sprite.play("Idle")
		await get_tree().create_timer(1).timeout
		animated_sprite.play("scaling_down")
	elif anim_name == "scaling_down":
		queue_free()
	
