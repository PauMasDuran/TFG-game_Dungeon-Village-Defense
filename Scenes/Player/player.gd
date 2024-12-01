extends CharacterBody2D

@export var health_points: int
var stamina_points: int
var dash_speed: int
var sp_drain: int

@export var speed: int
@export var knockback_strength: float = 10.0  # Adjust the force of knockback
@export var knockback_duration: float = 0.05 

var actionCapable = true
var attacking = false
var dashAvailable = true

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var lastVelocity = Vector2.ZERO

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats

@onready var playerStatsLevel = get_tree().get_root().get_node("Main").trainStats

@onready var smith = get_tree().get_root().get_node("Main").smith

@onready var gameHud = get_tree().get_root().get_node("Main").get_node("UI").get_node("GameHud")

@onready var camera = get_parent().get_node("GameCamera")

@onready var camera_limits = Vector2i(0,0)

var camera_limits_set: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	disable_all_hit_boxes()
	upgradePlayerStats()
	
	gameHud.resetSP()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !camera_limits_set:
		set_camera_limits()
	
	if knockback_timer > 0:
		apply_knockback(delta)
	
	movement_and_inputs(delta)

func movement_and_inputs(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if actionCapable:
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("melee_attack") and not attacking:
			attacking = true
			$AttackTimer.start()
			animateAttack(lastVelocity)
		if Input.is_action_pressed("dash") and dashAvailable and stamina_points >= 2:
			speed = dash_speed
			stamina_points -= 1
			gameHud.loseSP(1)
			$DashTimer.start()
			dashAvailable = false

	if velocity.length() > 0 and not attacking and actionCapable:
		velocity = velocity.normalized() * speed * delta
		lastVelocity = velocity.normalized()
		animateWalk(lastVelocity)
		move_and_collide(velocity)
		#position.x = round(position.x)
		#position.y = round(position.y)
	elif not attacking and actionCapable:
		animateIdle(lastVelocity)

func animateIdle(lastVelocity):
	if lastVelocity == Vector2.DOWN or lastVelocity == Vector2.ZERO:
		$Sprite2D/AnimationPlayer.play("Idle_down")
	elif lastVelocity == Vector2.RIGHT:
		$Sprite2D/AnimationPlayer.play("Idle_right")
	elif lastVelocity == Vector2.LEFT:
		$Sprite2D/AnimationPlayer.play("Idle_left")
	elif lastVelocity == Vector2.UP:
		$Sprite2D/AnimationPlayer.play("Idle_up")
	elif lastVelocity.x > 0 and lastVelocity.y > 0:
		$Sprite2D/AnimationPlayer.play("Idle_down_right")
	elif lastVelocity.x > 0 and lastVelocity.y < 0:
		$Sprite2D/AnimationPlayer.play("Idle_up_right")
	elif lastVelocity.x < 0 and lastVelocity.y > 0:
		$Sprite2D/AnimationPlayer.play("Idle_down_left")
	elif lastVelocity.x < 0 and lastVelocity.y < 0:
		$Sprite2D/AnimationPlayer.play("Idle_up_left")
	
func animateWalk(lastVelocity):
	if lastVelocity == Vector2.DOWN or lastVelocity == Vector2.ZERO:
		$Sprite2D/AnimationPlayer.play("Walk_down")
		#speed = playerStats.Spd
	elif lastVelocity == Vector2.RIGHT:
		$Sprite2D/AnimationPlayer.play("Walk_right")
		#speed = playerStats.Spd 
	elif lastVelocity == Vector2.LEFT:
		$Sprite2D/AnimationPlayer.play("Walk_left")
		#speed = playerStats.Spd 
	elif lastVelocity == Vector2.UP:
		$Sprite2D/AnimationPlayer.play("Walk_up")
		#speed = playerStats.Spd 
	elif lastVelocity.x > 0 and lastVelocity.y > 0:
		$Sprite2D/AnimationPlayer.play("Walk_down_right")
		#speed = playerStats.Spd + playerStats.Spd * 0.27
	elif lastVelocity.x > 0 and lastVelocity.y < 0:
		$Sprite2D/AnimationPlayer.play("Walk_up_right")
		#speed = playerStats.Spd + playerStats.Spd * 0.27
	elif lastVelocity.x < 0 and lastVelocity.y > 0:
		$Sprite2D/AnimationPlayer.play("Walk_down_left")
		#speed = playerStats.Spd + playerStats.Spd * 0.28
	elif lastVelocity.x < 0 and lastVelocity.y < 0:
		$Sprite2D/AnimationPlayer.play("Walk_up_left")
		#speed = playerStats.Spd + playerStats.Spd * 0.28
		
func animateAttack(lastVelocity):
	if lastVelocity == Vector2.DOWN or lastVelocity == Vector2.ZERO:
		$Sprite2D/AnimationPlayer.play("Atk_down")
		$HitBox/CollisionDown.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationDown.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationDown.play("slash animation")
	elif lastVelocity == Vector2.RIGHT:
		$Sprite2D/AnimationPlayer.play("Atk_right")
		$HitBox/CollisionRight.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationRight.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationRight.play("slash animation")
	elif lastVelocity == Vector2.LEFT:
		$Sprite2D/AnimationPlayer.play("Atk_left")
		$HitBox/CollisionLeft.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationLeft.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationLeft.play("slash animation")
	elif lastVelocity == Vector2.UP:
		$Sprite2D/AnimationPlayer.play("Atk_up")
		$HitBox/CollisionUp.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationUp.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationUp.play("slash animation")
	elif lastVelocity.x > 0 and lastVelocity.y > 0:
		$Sprite2D/AnimationPlayer.play("Atk_down_right")
		$HitBox/CollisionDownRight.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationDownRight.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationDownRight.play("slash animation")
	elif lastVelocity.x > 0 and lastVelocity.y < 0:
		$Sprite2D/AnimationPlayer.play("Atk_up_right")
		$HitBox/CollisionUpRight.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationUpRight.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationUpRight.play("slash animation")
	elif lastVelocity.x < 0 and lastVelocity.y > 0:
		$Sprite2D/AnimationPlayer.play("Atk_down_left")
		$HitBox/CollisionDownLeft.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationDownLeft.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationDownLeft.play("slash animation")
	elif lastVelocity.x < 0 and lastVelocity.y < 0:
		$Sprite2D/AnimationPlayer.play("Atk_up_left")
		$HitBox/CollisionLeftUp.disabled = false
		$Sprite2D/SlashAnimations/SlashAnimationUpLeft.visible = true
		$Sprite2D/SlashAnimations/SlashAnimationUpLeft.play("slash animation")

func apply_knockback(delta):
	knockback_timer -= delta  # Decrease timer
	move_and_collide(knockback_vector * speed * delta)
	if knockback_timer <= 0:
		knockback_vector = Vector2.ZERO  # Stop knockback when timer ends

# Trigger knockback when hit by the player
func receive_knockback_from_attack(area):
	knockback_vector = (global_position - area.owner.global_position).normalized() * knockback_strength
	knockback_timer = knockback_duration

func disable_all_hit_boxes():
	$HitBox/CollisionDown.disabled = true
	$HitBox/CollisionDownLeft.disabled = true
	$HitBox/CollisionDownRight.disabled = true
	$HitBox/CollisionLeft.disabled = true
	$HitBox/CollisionLeftUp.disabled = true
	$HitBox/CollisionUp.disabled = true
	$HitBox/CollisionUpRight.disabled = true
	$HitBox/CollisionRight.disabled = true
	
	$Sprite2D/SlashAnimations/SlashAnimationDown.visible = false
	$Sprite2D/SlashAnimations/SlashAnimationUp.visible = false
	$Sprite2D/SlashAnimations/SlashAnimationRight.visible = false
	$Sprite2D/SlashAnimations/SlashAnimationLeft.visible = false
	$Sprite2D/SlashAnimations/SlashAnimationDownRight.visible = false
	$Sprite2D/SlashAnimations/SlashAnimationDownLeft.visible = false
	$Sprite2D/SlashAnimations/SlashAnimationUpRight.visible = false
	$Sprite2D/SlashAnimations/SlashAnimationUpLeft.visible = false

func _on_attack_timer_timeout():
	disable_all_hit_boxes()
	attacking = false
	

func _on_dash_timer_timeout():
	speed = playerStats.Spd
	$DashCooldown.start()


func _on_dash_cooldown_timeout():
	dashAvailable = true


func _on_hurt_box_area_entered(area):
	if area.name == "EnemyHitBox":
		if health_points > 0:
			$Sprite2D/AnimationPlayer.play("TakeDmg_down")
			health_points -= 1
			gameHud.loseHP(1)
			$DamagedTimer.start()
			actionCapable = false
			receive_knockback_from_attack(area)
		else: 
			$Sprite2D/AnimationPlayer.play("Die_down")


func _on_damaged_timer_timeout():
	actionCapable = true


func _on_sp_regen_timeout():
	if stamina_points < playerStats.MaxSp:
		stamina_points += 1
		gameHud.gainSP(1)


func gotHitByPlayer():
	if stamina_points < playerStats.MaxSp:
		stamina_points += sp_drain
		gameHud.gainSP(sp_drain)


func set_camera_limits():
	camera_limits_set = true
	var parentNode = get_parent()
	if parentNode.is_in_group("DungeonGenerator"):
		camera.limit_left = 0      # Adjust to the desired left limit
		camera.limit_right = parentNode.CELL_SIZE * parentNode.WIDTH # Adjust to the desired right limit
		camera.limit_top = 0       # Adjust to the desired top limit
		camera.limit_bottom = parentNode.CELL_SIZE * parentNode.HEIGHT
	elif parentNode.name == "TutorialDungeon":
		camera.limit_left = 0      # Adjust to the desired left limit
		camera.limit_right = 25*64 # Adjust to the desired right limit
		camera.limit_top = 0       # Adjust to the desired top limit
		camera.limit_bottom = 64*64
	else:
		camera.limit_left = 0      
		camera.limit_right = 32 * 32 
		camera.limit_top = 0       
		camera.limit_bottom = 17 * 32


func upgradePlayerStats():
	playerStats.MaxHp = playerStatsLevel.HPTraining[playerStatsLevel.HPLevel]
	playerStats.Atk = playerStatsLevel.ATKTraining[playerStatsLevel.ATKLevel]
	playerStats.Spd = playerStatsLevel.SPDTraining[playerStatsLevel.SPDLevel]
	
	speed = playerStats.Spd
	health_points = playerStats.MaxHp
	stamina_points = playerStats.MaxSp
	
	playerStats.MaxSp = smith.SPCapacity[smith.SPLevel]
	playerStats.SPDrain = smith.SPDrain[smith.SPDrainLevel]
	playerStats.SprintSpd = smith.SprintBoots[smith.SprintLevel]
	
	stamina_points = playerStats.MaxSp
	sp_drain = playerStats.SPDrain
	dash_speed = playerStats.SprintSpd
