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

var orcActualDirection: Vector2 = Vector2.ZERO

var boss_is_in_teleporter:bool = false

var player: CharacterBody2D = null

var attacking: bool = false
var special_attacking:bool = false

var idling: bool = false
var hurting: bool = false

var dead: bool = false

var decoy: StaticBody2D

var aggro_to_player: bool = false

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
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	print(decoy)
	if knockback_timer > 0:
		apply_knockback(delta)
	if not dead and not hurting:
		if decoy == null and distance_to_player() > 150:
			target_wall(delta)
		elif decoy != null and not aggro_to_player:
			target_decoy(delta)
		elif aggro_to_player or distance_to_player() <= 150:
			target_player(delta)
	

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

func distance_to_player():
	return self.global_position.distance_to(player.global_position)

func distance_to_wall():
	return 481 - self.global_position.y 

func distance_to_decoy():
	return self.global_position.distance_to(decoy.global_position)

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
			print(health_points)
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
