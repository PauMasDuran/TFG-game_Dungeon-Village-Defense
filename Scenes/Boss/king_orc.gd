extends CharacterBody2D

@export var health_points: int = 50
@export var speed: float = 60.0
@export var atk: int = 2
@export var run_detection_radius: float = 120.0
@export var attack_detection_radius: float = 30.0
@export var knockback_strength: float = 10.0
@export var knockback_duration: float = 0.05
@export var auraType: String

var explosive_barrel = preload("res://Scenes/Boss/explosive_barrel.tscn")

var runSpeed: float = speed*1.5

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var idle_moving: bool = false
var idle_movement_direction: Vector2 = Vector2.ZERO

var orcActualDirection: Vector2 = Vector2.ZERO

var player: CharacterBody2D = null

var attacking: bool = false
var monster_spawning: bool = false
var lightning_spawning:bool = false
var special_attacking:bool = false
var barrel_exists:bool = false

var idling: bool = false
var hurting: bool = false
var walking: bool = false

var dead: bool = false

var decoy: StaticBody2D

var aggro_to_player: bool = false

var is_in_teleporter:bool = false


@export var default_general_number:int
var actual_general_number:int = 0
@export var default_minion_number:int
var actual_minion_number:int = 0
var general_orc = preload("res://Scenes/Boss/general_orc.tscn")
var minion_orc = preload("res://Scenes/Boss/minion_orc.tscn")
var inital_spawn_done:bool = false
var portal = preload("res://Scenes/Boss/boss_retinue_spawner.tscn")
var lightning = preload("res://Scenes/Boss/boss_lightning_attack.tscn")

@onready var audio_manager = $OrcAudioManager

@onready var animated_sprite = $AnimatedSprite2D

@onready var main = get_tree().get_root().get_node("Main")

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats

@onready var enemy_hit_box_collision_shapes_dict = {
	"collision_right":$EnemyHitBox/CollisionShapeRight,
	"collision_bot":$EnemyHitBox/CollisionShapeBot,
	"collision_left":$EnemyHitBox/CollisionShapeLeft,
	"collision_top":$EnemyHitBox/CollisionShapeTop
}

var enemy_box_collision_attack_index: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_root().get_node("Main").get_node("DungeonGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonGenerator").get_node("Player")
	elif get_parent().get_node("Player") != null:
		player = get_parent().get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("BossArena") != null:
		player = get_tree().get_root().get_node("Main").get_node("BossArena").get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator").get_node("Player")
	animated_sprite.play("idle_down")
	for collisionKeys in enemy_hit_box_collision_shapes_dict.keys():
		enemy_hit_box_collision_shapes_dict[collisionKeys].disabled = true
	$MonsterHPBar.max_value = health_points
	$MonsterHPBar.value = health_points
	$MonsterHPBar.visible = false
	$SpawningTimer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !inital_spawn_done:
		initial_spawn()
	if knockback_timer > 0:
		apply_knockback(delta)
	if not dead and not hurting:
		if is_in_teleporter:
			if not lightning_spawning: 
				if distance_to_player() < 150:
					spawn_lightning(player.global_position.x,player.global_position.y)
					lightning_spawning = true
			elif not monster_spawning:
				if distance_to_player() >= 150 and actual_general_number < default_general_number:
					spawn_general(328,114)
					monster_spawning = true
					$SpawningTimer.start()
				elif distance_to_player() >= 150 and actual_minion_number < default_minion_number:
					spawn_minion(328,114)
					monster_spawning = true
					$SpawningTimer.start()
			animated_sprite.play("idle_down")
		elif !is_in_teleporter and !aggro_to_player:
			move_towards_teleporter(delta)
		elif aggro_to_player:
			target_player(delta)


func initial_spawn():
	spawn_minion(272,114)
	spawn_minion(328,114)
	spawn_minion(378,114)
	spawn_general(378,75)
	spawn_general(272,75)
	inital_spawn_done = true

func get_orc_spawning_position():
	var total_actual_orcs = actual_general_number + actual_minion_number
	var total_orcs = default_general_number + default_minion_number
	return position + (Vector2.RIGHT.rotated((total_actual_orcs/total_orcs*PI)).normalized() * 100)

func spawn_minion(posX,posY):
	var minion_instance = minion_orc.instantiate()
	minion_instance.global_position = Vector2i(posX,posY)
	minion_instance.king = self
	spawn_portal_animation(posX,posY)
	await get_tree().create_timer(1).timeout
	get_parent().get_parent().get_node("Orcs").add_child(minion_instance)
	actual_minion_number += 1

func spawn_general(posX,posY):
	var general_instance = general_orc.instantiate()
	general_instance.global_position = Vector2i(posX,posY)
	general_instance.king = self
	spawn_portal_animation(posX,posY)
	await get_tree().create_timer(1).timeout
	get_parent().get_parent().get_node("Orcs").add_child(general_instance)
	actual_general_number += 1

func spawn_portal_animation(posX,posY):
	var portal_instance = portal.instantiate()
	portal_instance.global_position = Vector2(posX,posY)
	get_parent().get_parent().get_node("Orcs").add_child(portal_instance)
	

func spawn_lightning(posX,posY):
	var lightning_instance = lightning.instantiate()
	lightning_instance.global_position = Vector2(posX, posY)
	lightning_instance.atk = atk
	get_parent().get_parent().get_node("Projectiles").add_child(lightning_instance)
	print("lightning")
	$LightningTimer.start()

func move_towards_teleporter(delta):
	var direction = (Vector2(328,73) - global_position).normalized()
	orcActualDirection = direction
	move_and_collide(direction * speed * delta)
	animate_walk(direction)

func emit_signal_to_retinue():
	pass

func spawn_barrel():
	var barrel_instance = explosive_barrel.instantiate()
	barrel_instance.position = position + orcActualDirection * 30
	barrel_instance.orc_general_owner = self
	get_parent().get_node("Projectiles").add_child(barrel_instance)

func target_decoy(delta):
	if distance_to_decoy() > attack_detection_radius and not attacking:
		move_towards_decoy(delta)
	elif distance_to_decoy() <= attack_detection_radius and not attacking:
		attack_decoy()
	
func move_towards_decoy(delta):
	var direction = (decoy.global_position - global_position).normalized()
	orcActualDirection = direction
	move_and_collide(direction * speed * delta)
	animate_walk(direction)

func attack_decoy():
	var direction = (decoy.global_position - global_position).normalized()
	orcActualDirection = direction
	attacking = true
	animate_attack(orcActualDirection)
	$AttackTimer.start()
	$AttackCastingTimer.start()
	if not barrel_exists:
		spawn_barrel()
		barrel_exists = true

func target_player(delta):
	if distance_to_player() > attack_detection_radius and not attacking:
		move_towards_player(delta)
	elif distance_to_player() <= attack_detection_radius and not attacking:
		attack_player()

func attack_player():
	var direction = (player.global_position - global_position).normalized()
	orcActualDirection = direction
	attacking = true
	animate_attack(orcActualDirection)
	$AttackTimer.start()
	$AttackCastingTimer.start()

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	orcActualDirection = direction
	move_and_collide(direction * speed * delta)
	animate_walk(direction)


func target_wall(delta):
	if distance_to_wall() > attack_detection_radius /2 and not attacking:
		move_towards_wall(delta)
	elif distance_to_wall() <= attack_detection_radius/2 and not attacking:
		attack_wall()

func move_towards_wall(delta):
	var direction = Vector2.DOWN
	orcActualDirection = direction
	move_and_collide(direction * speed * delta)
	animate_walk(direction)

func attack_wall():
	var direction = Vector2.DOWN
	orcActualDirection = direction
	attacking = true
	animate_attack(orcActualDirection)
	$AttackTimer.start()
	$AttackCastingTimer.start()
	if not barrel_exists:
		spawn_barrel()
		barrel_exists = true

func distance_to_player():
	return self.global_position.distance_to(player.global_position)

func distance_to_wall():
	return 481 - self.global_position.y 

func distance_to_decoy():
	return self.global_position.distance_to(decoy.global_position)

func animate_walk(slimeActualDirection):
	if not walking:
		$WalkingTimer.start()
		walking = true
		audio_manager.play_walking_sound()
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animated_sprite.play("walk_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animated_sprite.play("walk_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animated_sprite.play("walk_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animated_sprite.play("walk_up")

func animate_run(slimeActualDirection):
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animated_sprite.play("run_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animated_sprite.play("run_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animated_sprite.play("run_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animated_sprite.play("run_up")

func animate_attack(slimeActualDirection):
	audio_manager.play_attacking_sound()
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animated_sprite.play("attack_right")
		enemy_box_collision_attack_index = "collision_right"
	elif angle > PI/3 and angle <= PI*2/3:
		animated_sprite.play("attack_down")
		enemy_box_collision_attack_index = "collision_bot"
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animated_sprite.play("attack_left")
		enemy_box_collision_attack_index = "collision_left"
	elif angle > -PI*2/3 and angle <= -PI/3:
		animated_sprite.play("attack_up")
		enemy_box_collision_attack_index = "collision_top"

func animate_hurt(slimeActualDirection):
	audio_manager.play_hurt_sound()
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animated_sprite.play("hurt_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animated_sprite.play("hurt_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animated_sprite.play("hurt_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animated_sprite.play("hurt_up")

func animate_death(slimeActualDirection):
	audio_manager.play_dying_sound()
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animated_sprite.play("death_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animated_sprite.play("death_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animated_sprite.play("death_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animated_sprite.play("death_up")


func _on_enemy_hit_box_area_entered(area):
	pass # Replace with function body.


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		if area.owner.name =="Player":
			player.gotHitByPlayer()
			aggro_to_player = true
			$AggroTimer.start()
		if health_points >= 1:
			hurting = true
			animate_hurt(orcActualDirection)
			health_points -= playerStats.Atk
			$DamagedTimer.start()
			$MonsterHPBar.value = health_points
			$MonsterHPBar.visible = true
			recieve_knockback_from_area(area)
			if health_points < 1 and not dead: 
				hurting = true
				dead = true
				$MonsterHPBar.visible = false
				$EnemyHitBox.visible = false
				$CollisionShape2D.disabled = true
				$HurtBox.visible = false
				recieve_knockback_from_area(area)
				death()

func death():
	hurting = true
	dead = true
	animate_death(orcActualDirection)
	aggro_to_player = false
	
	$DeathTimer.start()

func apply_knockback(delta):
	knockback_timer -= delta  # Decrease timer
	move_and_collide(knockback_vector * speed * delta)
	if knockback_timer <= 0:
		knockback_vector = Vector2.ZERO  # Stop knockback when timer ends

# Trigger knockback when hit by the player
func recieve_knockback_from_area(area):
	knockback_vector = (global_position - area.owner.global_position).normalized() * knockback_strength
	knockback_timer = knockback_duration

func _on_death_timer_timeout():
	main.exit_boss_arena()
	queue_free()


func _on_damaged_timer_timeout():
	hurting = false



func _on_attack_timer_timeout():
	enemy_hit_box_collision_shapes_dict[enemy_box_collision_attack_index].disabled = true
	await get_tree().create_timer(0.3).timeout
	attacking = false


func _on_attack_casting_timer_timeout():
	enemy_hit_box_collision_shapes_dict[enemy_box_collision_attack_index].disabled = false


func _on_aggro_timer_timeout():
	aggro_to_player = false


func _on_spawning_timer_timeout():
	monster_spawning = false


func _on_lightning_timer_timeout():
	lightning_spawning = false

func _on_walking_timer_timeout():
	walking = false
