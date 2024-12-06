extends Node2D

var slimeBoss = preload("res://Scenes/Boss/boss_slimes.tscn")
var green_slime = preload("res://Scenes/Boss/boss_slime_green.tres")
var red_slime = preload("res://Scenes/Boss/boss_slime_red.tres")
var blue_slime = preload("res://Scenes/Boss/boss_slime_blue.tres")


var slime_boss_in_center: bool
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func spawn_slime_boss():
	$AnimatedSprite2D.play("spawn")
	var slime_types = [green_slime,red_slime,blue_slime]
	var slimeBoss_instance = slimeBoss.instantiate()
	slimeBoss_instance.get_node("AnimatedSprite2D").sprite_frames = slime_types[randi_range(0,2)]
	slimeBoss_instance.get_node("EnemyHitBox").get_node("CollisionShape2D").disabled = true
	
	add_child(slimeBoss_instance)


func _on_teleporter_center_body_entered(body):
	slime_boss_in_center = true


func _on_teleporter_center_body_exited(body):
	slime_boss_in_center = false

func boss_was_defeated():
	get_parent().normal_mode()
