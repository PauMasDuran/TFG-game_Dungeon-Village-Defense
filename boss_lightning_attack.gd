extends Node2D

var lightning_strikes = ["lightning1","lightning2","lightning3","lightning4"]
var atk: int
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$EnemyHitBox/CollisionShape2D.disabled = true
	$AnimatedSprite2D.play(lightning_strikes[randi_range(0,3)]) 

func _on_casting_timer_timeout():
	$EnemyHitBox/CollisionShape2D.disabled = false



func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation in lightning_strikes:
		queue_free()
