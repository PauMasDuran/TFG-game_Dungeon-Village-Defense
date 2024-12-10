extends CharacterBody2D

@export var health_points: int = 50
@export var speed: float = 60.0
@export var atk: int = 2
@export var run_detection_radius: float = 120.0
@export var attack_detection_radius: float = 30.0
@export var knockback_strength: float = 10.0
@export var knockback_duration: float = 0.05
@export var auraType: String

var runSpeed: float = speed*1.5

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var idle_moving: bool = false
var idle_movement_direction: Vector2 = Vector2.ZERO

var slimeActualDirection: Vector2 = Vector2.ZERO

var boss_is_in_teleporter:bool = false

var player: CharacterBody2D = null

var attacking: bool = false
var special_attacking:bool = false

var idling: bool = false
var hurting: bool = false

var dead: bool = false

var boss_mode: bool = false

@onready var animated_sprite = $AnimatedSprite2D

@onready var main = get_tree().get_root().get_node("Main")

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if get_tree().get_root().get_node("Main").get_node("DungeonGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonGenerator").get_node("Player")
	elif get_parent().get_node("Player") != null:
		player = get_parent().get_node("Player")
	elif get_parent().get_parent().get_node("Player") != null:
		player = get_parent().get_parent().get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("BossArena") != null:
		player = get_tree().get_root().get_node("Main").get_node("BossArena").get_node("Player")
	elif get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator") != null:
		player = get_tree().get_root().get_node("Main").get_node("DungeonFloorGenerator").get_node("Player")
	$EnemyPowerLevel.actualize_power_level("BossSlime",main.actual_dungeon_floor,auraType)
	$EnemyHitBox/CollisionShape2D.disabled = true
	$MonsterHPBar.max_value = health_points
	$MonsterHPBar.value = health_points

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if knockback_timer > 0:
		apply_knockback(delta)
	
	if !boss_mode and not dead:
		normal_battle_mode(delta)
	elif not dead:
		special_battle_mode(delta)


func normal_battle_mode(delta):
	var distance_to_player = distance_to_player()
	if  distance_to_player < attack_detection_radius and not attacking and not hurting and not dead:
		normal_attack_player()
	if distance_to_player < run_detection_radius and not attacking and not hurting and not dead:
		run_towards_player(delta)
		
	elif distance_to_player >= run_detection_radius and not attacking and not hurting and not dead:
		walk_towards_player(delta)

func special_battle_mode(delta):
	if !boss_is_in_teleporter:
		run_towards_teleporter(delta)
	elif boss_is_in_teleporter and not idling and not hurting and not dead: 
		animate_idle()
		idling = true
		if !special_attacking:
			special_attacks()
	elif hurting and not dead:
		boss_mode = false
	elif not idling:
		idling = true
		animate_idle()

func run_towards_teleporter(delta):
	var direction = (get_parent().global_position - global_position).normalized()
	slimeActualDirection = direction
	move_and_collide(direction * runSpeed * delta)
	animate_run(direction)

func special_attacks():
	special_attacking = true
	$SpecialAttackTimer.start()

func distance_to_player():
	return self.global_position.distance_to(player.global_position)

func walk_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	slimeActualDirection = direction
	move_and_collide(direction * speed * delta)
	animate_walk(direction)

func run_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	slimeActualDirection = direction
	move_and_collide(direction * runSpeed * delta)
	animate_run(direction)

func normal_attack_player():
	attacking = true
	var direction = (player.global_position - global_position).normalized()
	animate_attack(direction)
	$NormalAttackCastingTimer.start()
	

func animate_idle():
	animated_sprite.play("idle_down")

func apply_knockback(delta):
	knockback_timer -= delta  # Decrease timer
	move_and_collide(knockback_vector * speed * delta)
	if knockback_timer <= 0:
		knockback_vector = Vector2.ZERO  # Stop knockback when timer ends

# Trigger knockback when hit by the player
func recieve_knockback_from_area(area):
	knockback_vector = (global_position - area.owner.global_position).normalized() * knockback_strength
	knockback_timer = knockback_duration

func animate_walk(slimeActualDirection):
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
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animated_sprite.play("attack_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animated_sprite.play("attack_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animated_sprite.play("attack_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animated_sprite.play("attack_up")

func animate_hurt(slimeActualDirection):
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
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animated_sprite.play("death_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animated_sprite.play("death_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animated_sprite.play("death_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animated_sprite.play("death_up")



func _on_normal_attack_casting_timer_timeout():
	$EnemyHitBox/CollisionShape2D.disabled = false
	$NormalAttackTimer.start()
	

func _on_normal_attack_timer_timeout():
	$EnemyHitBox/CollisionShape2D.disabled = true
	


func _on_damaged_timer_timeout():
	hurting = false


func _on_death_timer_timeout():
	queue_free()


func _on_animated_sprite_2d_animation_finished():
	idling = false
	if animated_sprite.animation == "attack_down":
		attacking = false
	elif animated_sprite.animation == "attack_up":
		attacking = false
	elif animated_sprite.animation == "attack_right":
		attacking = false
	elif animated_sprite.animation == "attack_left":
		attacking = false
	elif animated_sprite.animation == "hurt_down":
		hurting = false
		attacking = false
	elif animated_sprite.animation == "hurt_up":
		hurting = false
		attacking = false
	elif animated_sprite.animation == "hurt_right":
		hurting = false
		attacking = false
	elif animated_sprite.animation == "hurt_left":
		hurting = false
		attacking = false
	elif animated_sprite.animation == "idle_down":
		idling = false
	elif animated_sprite.animation == "death_down":
		animated_sprite.visible == false
	elif animated_sprite.animation == "death_up":
		animated_sprite.visible == false
	elif animated_sprite.animation == "death_right":
		animated_sprite.visible == false
	elif animated_sprite.animation == "death_left":
		animated_sprite.visible == false


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		player.gotHitByPlayer()
		if health_points >= 1:
			hurting = true
			$NormalAttackCastingTimer.stop()
			$NormalAttackTimer.stop()
			animate_hurt(slimeActualDirection)
			health_points -= playerStats.Atk
			$DamagedTimer.start()
			$MonsterHPBar.value = health_points
			recieve_knockback_from_area(area)
			if health_points < 1 and not dead: 
				hurting = true
				dead = true
				$MonsterHPBar.visible = false
				$EnemyHitBox.visible = false
				$CollisionShape2D.disabled = true
				$HurtBox.visible = false
				recieve_knockback_from_area(area)
				drop_loot()
				death()

func drop_loot():
	var auraTypes = ["","none","green","blue","red","black"]
	var lootQuantity = randi_range(15,30) 
	main.addGold(round(lootQuantity * $EnemyPowerLevel.get_floor_boost(main.actual_dungeon_floor) * auraTypes.find(auraType)))

func death():
	hurting = true
	dead = true
	$Aura.visible = false
	animate_death(slimeActualDirection)
	if get_parent().name == "SlimeBossSpawner":
		get_parent().boss_was_defeated()
	$DeathTimer.start()


func _on_special_attack_timer_timeout():
	if randi() % 2 == 0:
		get_parent().call_random_saturation_lightning_strikes(atk,self)
	else:
		get_parent().call_guided_lightning_strikes(atk,player,self)


func _on_mode_timer_timeout():
	if boss_mode == false:
		boss_mode = true
		idling = false
	elif boss_mode == true:
		boss_mode = false
		idling = false
