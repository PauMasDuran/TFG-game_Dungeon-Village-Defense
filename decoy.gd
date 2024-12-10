extends StaticBody2D

@export var health_points : int = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	$DecoyHPBar.max_value = health_points
	$DecoyHPBar.value = health_points


func _on_hurt_box_area_entered(area):
	if area.name == "EnemyHitBox":
		if health_points > 0:
			health_points -= area.owner.atk
			$DecoyHPBar.value = health_points
			#actionCapable = false
		elif health_points <= 0:
			queue_free()


func _on_aggro_zone_body_entered(body):
	if body.is_in_group("Monsters"):
		body.decoy = self



func _on_aggro_zone_body_exited(body):
	if body.is_in_group("Monsters") and body.decoy == self:
		body.decoy = null
