extends CharacterBody2D

@export var health_points: int = 4
@export var speed: float = 50.0
@export var atk: int = 20
@export var detection_radius: float = 200.0
@export var knockback_strength: float = 10.0
@export var knockback_duration: float = 0.05  
@export var auraType: String

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var idle_moving: bool = false
var idle_movement_direction: Vector2 = Vector2.ZERO

var player: CharacterBody2D = null

var monster_spawner: StaticBody2D = null

var hurting: bool = false

var dead: bool = false

@onready var main = get_tree().get_root().get_node("Main")

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats
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
	print(player)
	$EnemyPowerLevel.actualize_power_level("Slime",main.actual_dungeon_floor,auraType)
	$MonsterHPBar.max_value = health_points
	$MonsterHPBar.value = health_points
	$MonsterHPBar.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if knockback_timer > 0:
		apply_knockback(delta)
		
	if player and is_player_in_range() and not hurting and not dead:
		move_towards_player(delta)
	elif not hurting and not dead:
		idle_movement(delta)


func is_player_in_range() -> bool:
	
	return self.global_position.distance_to(player.global_position) <= detection_radius

func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	move_and_collide(direction * speed * delta)
	$Sprite2D/AnimationPlayer.play("walkAnimation")

func idle_movement(delta):
	if idle_moving == true:
		move_and_collide(idle_movement_direction * speed * delta)
		$Sprite2D/AnimationPlayer.play("walkAnimation")
	else:
		$Sprite2D/AnimationPlayer.play("RESET")

func apply_knockback(delta):
	knockback_timer -= delta  # Decrease timer
	move_and_collide(knockback_vector * speed * delta)
	if knockback_timer <= 0:
		knockback_vector = Vector2.ZERO  # Stop knockback when timer ends

# Trigger knockback when hit by the player
func recieve_knockback_from_area(area):
	knockback_vector = (global_position - area.owner.global_position).normalized() * knockback_strength
	knockback_timer = knockback_duration

func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		player.gotHitByPlayer()
		if health_points >= 1:
			hurting = true
			$Sprite2D/AnimationPlayer.play("TakeDmg")
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
	$Sprite2D/AnimationPlayer.play("Die")
	$Aura/CPUParticles2D.emitting = false
	$DeathTimer.start()

func _on_death_timer_timeout():
	drop_loot()
	queue_free()
	


func _on_damaged_timer_timeout():
	hurting = false


func _on_idle_movement_timer_timeout():
	if idle_moving == true:
		idle_moving = false
	else:
		idle_moving = true
		idle_movement_direction = Vector2(randf_range(-1,1),randf_range(-1,1))

func drop_loot():
	var auraTypes = ["","none","green","blue","red","black"]
	var lootQuantity = randi_range(15,30) 
	main.addGold(lootQuantity * main.actual_dungeon_floor * auraTypes.find("auraType"))
