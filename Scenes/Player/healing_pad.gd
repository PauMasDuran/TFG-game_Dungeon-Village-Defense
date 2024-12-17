extends Area2D

var healing_rate: int = 5
var heal:bool = false
var player:CharacterBody2D

@onready var structures = get_tree().get_root().get_node("Main").structures

# Called when the node enters the scene tree for the first time.
func _ready():
	healing_rate = structures.HealUpgrade[structures.HealLevel]




func _on_body_entered(body):
	if body.name == "Player":
		player = body
		heal = true
		$HealSound.play()


func _on_body_exited(body):
	if body.name == "Player":
		heal = false
		$HealSound.stop()


func _on_interval_between_healings_timer_timeout():
	if heal:
		player.is_in_healing_pad(healing_rate)
