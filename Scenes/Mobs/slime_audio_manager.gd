extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


func play_walking_sound():
	$WalkingSound.pitch_scale = randf_range(0.80,1.5)
	$WalkingSound.play()

func play_running_sound():
	$RunningSound.pitch_scale = randf_range(0.80,1.5)
	$RunningSound.play()

func play_attacking_sound():
	$AttackingSound.pitch_scale = randf_range(0.80,1.5)
	$AttackingSound.play()

func play_dashing_sound():
	$DashingSound.pitch_scale = randf_range(0.80,1.5)
	$DashingSound.play()

func play_hurt_sound():
	$HurtSound.pitch_scale = randf_range(0.80,1.5)
	$HurtSound.play()

func play_dying_sound():
	$DyingSound.pitch_scale = randf_range(0.80,1.5)
	$DyingSound.play()

func play_shooting_sound():
	$ShootingSound.pitch_scale = randf_range(0.80,1.5)
	$ShootingSound.play()
	
func play_magic_sound():
	$MagicSound.pitch_scale = randf_range(0.80,1.5)
	$MagicSound.play()

func play_parry_sound():
	$ParrySound.pitch_scale = randf_range(0.80,1.5)
	$ParrySound.play()
