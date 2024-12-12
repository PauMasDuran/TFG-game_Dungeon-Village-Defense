extends Node2D


@onready var animated_sprite = $AnimatedSprite2D
@onready var atk = 30

var orc_general_owner: CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite.play("arming")
	$EnemyHitBox/CollisionShape2D.disabled = true


func _on_bomb_timer_timeout():
	animated_sprite.play("explosion")
	$EnemyHitBox/CollisionShape2D.disabled = false


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		animated_sprite.play("off")
		if $BombTimer.is_stopped() == false:
			$BombTimer.stop()


func _on_enemy_hit_box_area_entered(area):
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "arming":
		animated_sprite.play("countdown")
		$BombTimer.start()
	if animated_sprite.animation == "explosion":
		if is_instance_valid(orc_general_owner):
			orc_general_owner.barrel_exists = false
		queue_free()
	if animated_sprite.animation == "off":
		await get_tree().create_timer(1).timeout
		if is_instance_valid(orc_general_owner):
			orc_general_owner.barrel_exists = false
		queue_free()
