extends Node2D

var slimeBoss = preload("res://Scenes/Boss/boss_slimes.tscn")
var green_slime = preload("res://Scenes/Boss/boss_slime_green.tres")
var red_slime = preload("res://Scenes/Boss/boss_slime_red.tres")
var blue_slime = preload("res://Scenes/Boss/boss_slime_blue.tres")

var lightning_attack = preload("res://Scenes/Boss/boss_lightning_attack.tscn")

var player: CharacterBody2D = null

var auraTypes = ["none","green","blue","red","black"]
var no_aura: int = 4
var auraColor: int

var is_slime_dead: bool = false 

@onready var main = get_tree().get_root().get_node("Main")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if get_parent().get_node("Player") != null:
		player = get_parent().get_node("Player")

func spawn_slime_boss():
	$AnimatedSprite2D.play("spawn")
	var auraColor = randi_range(0,main.actual_dungeon_floor)
	var slime_types = [green_slime,red_slime,blue_slime]
	var slimeBoss_instance = slimeBoss.instantiate()
	slimeBoss_instance.auraType = auraTypes[auraColor]
	slimeBoss_instance.get_node("AnimatedSprite2D").sprite_frames = slime_types[randi_range(0,2)]
	slimeBoss_instance.get_node("EnemyHitBox").get_node("CollisionShape2D").disabled = true
	
	add_child(slimeBoss_instance)

func spawn_lightning_strike(posX,posY,slimeAtk,slime):
	var lightning_instance = lightning_attack.instantiate()
	lightning_instance.global_position = Vector2(posX - position.x, posY - position.y)
	lightning_instance.atk = slimeAtk
	add_child(lightning_instance)

func call_random_saturation_lightning_strikes(slimeAtk,slime):
	var number_of_lightning = randi_range(7, 15)
	for strike in range(number_of_lightning):
		var posX = randi_range(336,816)
		var posY = randi_range(592,816)
		if is_slime_dead == false:
			spawn_lightning_strike(posX,posY,slimeAtk,slime)
	if is_slime_dead == false:
		await get_tree().create_timer(0.5).timeout
		slime.special_attacking = false

func spawn_guided_lightning_strike(posX,posY,slimeAtk, player,slime):
	var lightning_instance = lightning_attack.instantiate()
	lightning_instance.global_position = Vector2(player.global_position.x + posX - position.x, player.global_position.y + posY - position.y)
	lightning_instance.atk = slimeAtk
	add_child(lightning_instance)

func call_guided_lightning_strikes(slimeAtk, player,slime):
	var number_of_lightning = randi_range(7, 15)
	for strike in range(number_of_lightning):
		var posX = randi_range(-50,50)
		var posY = randi_range(-50,50)
		if is_slime_dead == false:
			spawn_guided_lightning_strike(posX,posY,slimeAtk,player,slime)
		await get_tree().create_timer(0.5).timeout
	if is_slime_dead == false:
		await get_tree().create_timer(0.5).timeout
		slime.special_attacking = false

func _on_teleporter_center_body_entered(body):
	body.boss_is_in_teleporter = true

func _on_teleporter_center_body_exited(body):
	body.boss_is_in_teleporter = false
	body.boss_mode = false
	body.idling = false
	body.get_node("ModeTimer").stop()
	body.get_node("ModeTimer").start()

func boss_was_defeated():
	get_parent().normal_mode()
	is_slime_dead = true
