extends CharacterBody2D

@export var speed: float = 60.0
@export var attacking_range: float = 100.0

var attacking: bool = false

var archerActualDirection: Vector2 = Vector2.UP

var enemies_in_Area: Array = []

var enemy_target: CharacterBody2D

@onready var projectile = load("res://Scenes/Player/archer_arrow_projectile.tscn")

@onready var projectiles_node = get_tree().get_root().get_node("Main").get_node("Projectiles")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if not attacking and get_enemy_target() and enemy_target_in_range():
		var direction = (enemy_target.global_position - global_position).normalized()
		archerActualDirection = direction
		attacking = true
		animateRangedAtk(archerActualDirection)
		$RangedAttackCastingTimer.start()
		$RangedAttackTimer.start()
		print("Attacking")
	elif not attacking and get_enemy_target() and not enemy_target_in_range():
		move_towards_enemy_target(delta)
		print("moving")
	elif not attacking and not get_enemy_target() and not enemy_target_in_range():
		archerActualDirection = Vector2.UP
		animateIdle(archerActualDirection)


func move_towards_enemy_target(delta):
	var direction = (enemy_target.global_position - global_position)
	print(direction.x)
	if direction.x > 50:
		direction = Vector2.RIGHT
		archerActualDirection = direction
		move_and_collide(direction * speed * delta)
		animateWalk(direction)
	elif direction.x < -50:
		direction = Vector2.LEFT
		archerActualDirection = direction
		move_and_collide(direction * speed * delta)
		animateWalk(direction)
	else:
		direction = Vector2.UP
		animateIdle(direction) 
	

func enemy_target_in_range():
	if enemy_target != null:
		return self.global_position.distance_to(enemy_target.global_position) < attacking_range

func get_enemy_target():
	if enemies_in_Area.size() != 0:
		enemy_target = enemies_in_Area[0]
		for enemy in enemies_in_Area:
			if self.global_position.distance_to(enemy.global_position) < self.global_position.distance_to(enemy_target.global_position):
				enemy_target = enemy 
		print("Got enemy target")
		return true
	else:
		return false


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

func _on_ranged_attack_timer_timeout():
	attacking = false


func _on_ranged_attack_casting_timer_timeout():
		var projectile_instance = projectile.instantiate()
		projectile_instance.spawnPos = global_position
		projectile_instance.spawnRot = archerActualDirection.angle()
		projectile_instance.zdex = z_index + 1
		projectiles_node.add_child(projectile_instance)


func _on_range_area_detection_body_entered(body):
	if body.is_in_group("Monsters"):
		enemies_in_Area.append(body)


func _on_range_area_detection_body_exited(body):
	if body.is_in_group("Monsters"):
		enemies_in_Area.erase(body)
