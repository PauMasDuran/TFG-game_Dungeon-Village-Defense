extends CharacterBody2D

@export var health_points: int = 4
@export var speed: float = 60.0
@export var detection_radius: float = 200.0
@export var knockback_strength: float = 10.0
@export var knockback_duration: float = 0.05

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var idle_moving: bool = false
var idle_movement_direction: Vector2 = Vector2.ZERO

var orcActualDirection: Vector2 = Vector2.ZERO

var player: CharacterBody2D = null

var monster_spawner: StaticBody2D = null

var attacking: bool = false
# 0 = melee, 1 = ranged, 2 = magic, 
var attackType: int = 0
var hurting: bool = false

var dead: bool = false

@onready var projectile = load("res://Scenes/Mobs/arrow_projectile.tscn")

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats

@onready var projectiles_node = get_tree().get_root().get_node("Main").get_node("Projectiles")

@onready var main = get_tree().get_root().get_node("Main")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if get_tree().get_root().get_node("Main").get_node("DungeonGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonGenerator").get_node("Player")
	elif get_parent().get_node("Player") != null:
		player = get_parent().get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("BossArena") != null:
		player = get_tree().get_root().get_node("Main").get_node("BossArena").get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator").get_node("Player")
	$MonsterHPBar.max_value = health_points
	$MonsterHPBar.value = health_points
	$MonsterHPBar.visible = false
	
	$EnemyHitBox/CollisionShape2D.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if knockback_timer > 0:
		apply_knockback(delta)
	
	#for Ranged Orc
	#if attackType == 1 and not attacking and not hurting:
		#var direction = (player.global_position - global_position).normalized()
		#orcActualDirection = direction
		#attacking = true
		#animateRangedAtk(orcActualDirection)
		#$RangedAttackCastingTimer.start()
		#$RangedAttackTimer.start()
		#$RangeAreaDetection/CollisionShape2D.disabled = true
		#$RangeAreaDetection.monitoring = false
	
	if player and is_player_in_range() and not hurting and not attacking:
		move_towards_player(delta)
	elif not hurting and not attacking:
		idle_movement(delta)



func is_player_in_range() -> bool:
	return self.global_position.distance_to(player.global_position) <= detection_radius

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	orcActualDirection = direction
	move_and_collide(direction * speed * delta)
	animateWalk(direction)
	#print(direction)

func idle_movement(delta):
	if idle_moving == true:
		move_and_collide(idle_movement_direction * speed * delta)
		animateWalk(idle_movement_direction)
		orcActualDirection = idle_movement_direction
	else:
		animateIdle(idle_movement_direction)
		orcActualDirection = idle_movement_direction

func animateWalk(lastVelocity):
	var angle = lastVelocity.angle()
	if angle >= -PI/8 and angle < PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_right")
	elif angle >= PI/8 and angle < 3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_down_right")
	elif angle >= 3 * PI/8 and angle < 5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_down")
	elif angle >= 5 * PI/8 and angle < 7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_down_left")
	elif angle >= 7 * PI/8 or angle < -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_left")
	elif angle < -5 * PI/8 and angle >= -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_up_left")
	elif angle < -3 * PI/8 and angle >= -5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_up")
	elif angle < -PI/8 and angle >= -3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Walk_up_right")

func animateIdle(lastVelocity):
	var angle = lastVelocity.angle()
	if angle >= -PI/8 and angle < PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_right")
	elif angle >= PI/8 and angle < 3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_down_right")
	elif angle >= 3 * PI/8 and angle < 5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_down")
	elif angle >= 5 * PI/8 and angle < 7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_down_left")
	elif angle >= 7 * PI/8 or angle < -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_left")
	elif angle < -5 * PI/8 and angle >= -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_up_left")
	elif angle < -3 * PI/8 and angle >= -5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_up")
	elif angle < -PI/8 and angle >= -3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Idle_up_right")

func animateAtk(lastVelocity):
	var angle = lastVelocity.angle()
	if angle >= -PI/8 and angle < PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_right")
	elif angle >= PI/8 and angle < 3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_down_right")
	elif angle >= 3 * PI/8 and angle < 5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_down")
	elif angle >= 5 * PI/8 and angle < 7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_down_left")
	elif angle >= 7 * PI/8 or angle < -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_left")
	elif angle < -5 * PI/8 and angle >= -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_up_left")
	elif angle < -3 * PI/8 and angle >= -5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_up")
	elif angle < -PI/8 and angle >= -3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Atk_up_right")

func animateRangedAtk(lastVelocity):
	var angle = lastVelocity.angle()
	if angle >= -PI/8 and angle < PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_right")
	elif angle >= PI/8 and angle < 3 * PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_down_right")
	elif angle >= 3 * PI/8 and angle < 5 * PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_down")
	elif angle >= 5 * PI/8 and angle < 7 * PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_down_left")
	elif angle >= 7 * PI/8 or angle < -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_left")
	elif angle < -5 * PI/8 and angle >= -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_up_left")
	elif angle < -3 * PI/8 and angle >= -5 * PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_up")
	elif angle < -PI/8 and angle >= -3 * PI/8:
		$Sprite2D/AnimationPlayer.play("RangedAtk_up_right")

func animateDie(lastVelocity):
	var angle = lastVelocity.angle()
	if angle >= -PI/8 and angle < PI/8:
		$Sprite2D/AnimationPlayer.play("Die_right")
	elif angle >= PI/8 and angle < 3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Die_down_right")
	elif angle >= 3 * PI/8 and angle < 5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Die_down")
	elif angle >= 5 * PI/8 and angle < 7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Die_down_left")
	elif angle >= 7 * PI/8 or angle < -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Die_left")
	elif angle < -5 * PI/8 and angle >= -7 * PI/8:
		$Sprite2D/AnimationPlayer.play("Die_up_left")
	elif angle < -3 * PI/8 and angle >= -5 * PI/8:
		$Sprite2D/AnimationPlayer.play("Die_up")
	elif angle < -PI/8 and angle >= -3 * PI/8:
		$Sprite2D/AnimationPlayer.play("Die_up_right")

func apply_knockback(delta):
	knockback_timer -= delta  # Decrease timer
	move_and_collide(knockback_vector * speed * delta)
	if knockback_timer <= 0:
		knockback_vector = Vector2.ZERO  # Stop knockback when timer ends


func recieve_knockback_from_area(area):
	knockback_vector = (global_position - area.owner.global_position).normalized() * knockback_strength
	knockback_timer = knockback_duration

func _on_idle_movement_timer_timeout():
	if idle_moving == true:
		idle_moving = false
	else:
		idle_moving = true
		idle_movement_direction = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()


func _on_death_timer_timeout():
	queue_free()


func _on_damaged_timer_timeout():
	hurting = false


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		player.gotHitByPlayer()
		if health_points >= 1:
			hurting = true
			$Sprite2D/AnimationPlayer.play("TakeDmg_down")
			health_points -= playerStats.Atk
			print(health_points)
			$DamagedTimer.start()
			$MonsterHPBar.value = health_points
			$MonsterHPBar.visible = true
			recieve_knockback_from_area(area)
		elif health_points < 1 and not dead: 
			health_points -= playerStats.Atk
			print(health_points)
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
	drop_loot()
	animateDie(orcActualDirection)
	$DeathTimer.start()


func _on_enemy_hit_box_area_entered(area):
	pass


func _on_attack_timer_timeout():
	attacking = false
	$EnemyHitBox/CollisionShape2D.disabled = true
	$MeleeAreaDetection/CollisionShape2D.disabled = false


func _on_attack_casting_timer_timeout():
		$EnemyHitBox/CollisionShape2D.disabled = false


func _on_melee_area_detection_area_entered(area):
	if area.name == "PlayerHurtBox" and not dead:
		attackType = 0
		attacking = true
		animateAtk(orcActualDirection)
		$AttackTimer.start()
		$AttackCastingTimer.start()
		$MeleeAreaDetection/CollisionShape2D.disabled = true


func _on_range_area_detection_area_entered(area):
	if area.name == "PlayerHurtBox" and not dead:
		attackType = 1
		attacking = true
		animateRangedAtk(orcActualDirection)
		$RangedAttackCastingTimer.start()
		$RangedAttackTimer.start()
		$RangeAreaDetection/CollisionShape2D.disabled = true
		$RangeAreaDetection.monitoring = false


func _on_ranged_attack_timer_timeout():
	attacking = false
	$RangeAreaDetection/CollisionShape2D.disabled = false
	$RangeAreaDetection.monitoring = true


func _on_ranged_attack_casting_timer_timeout():
	var projectile_instance = projectile.instantiate()
	projectile_instance.spawnPos = global_position
	projectile_instance.spawnRot = orcActualDirection.angle()
	projectile_instance.zdex = z_index + 1
	projectiles_node.add_child(projectile_instance)

func drop_loot():
	var lootQuantity = randi_range(15,30) 
	main.addGold(lootQuantity)
