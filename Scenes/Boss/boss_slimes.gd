extends CharacterBody2D

@export var health_points: int = 4
@export var speed: float = 60.0
@export var atk: int 
@export var detection_radius: float = 200.0
@export var knockback_strength: float = 10.0
@export var knockback_duration: float = 0.05

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var idle_moving: bool = false
var idle_movement_direction: Vector2 = Vector2.ZERO

var slimeActualDirection: Vector2 = Vector2.ZERO

var player: CharacterBody2D = null

var attacking: bool = false

var hurting: bool = false

var dead: bool = false

@onready var animation = $AnimatedSprite2D

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_towards_player(delta)


func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	slimeActualDirection = direction
	move_and_collide(direction * speed * delta)
	#animate_walk(direction)
	animate_run(direction)

func animate_idle():
	pass

func animate_walk(slimeActualDirection):
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animation.play("walk_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animation.play("walk_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animation.play("walk_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animation.play("walk_up")

func animate_run(slimeActualDirection):
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animation.play("run_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animation.play("run_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animation.play("run_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animation.play("run_up")

func animate_attack(slimeActualDirection):
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animation.play("attack_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animation.play("attack_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animation.play("attack_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animation.play("attack_up")

func animate_hurt(slimeActualDirection):
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animation.play("hurt_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animation.play("hurt_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animation.play("hurt_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animation.play("hurt_up")

func animate_death(slimeActualDirection):
	var angle = slimeActualDirection.angle()
	if angle > -PI/3 and angle <= PI/3:
		animation.play("death_right")
	elif angle > PI/3 and angle <= PI*2/3:
		animation.play("death_down")
	elif angle > PI*2/3 or angle <= -PI*2/3:
		animation.play("death_left")
	elif angle > -PI*2/3 and angle <= -PI/3:
		animation.play("death_up")

func _on_enemy_hit_box_area_entered(area):
	pass # Replace with function body.


func _on_hurt_box_area_entered(area):
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished():
	pass # Replace with function body.
