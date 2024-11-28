extends StaticBody2D

var slime = preload("res://Scenes/Mobs/slime.tscn")
var base_orc = preload("res://Scenes/Mobs/base_orc.tscn")
var melee_orc = preload("res://Scenes/Mobs/melee_orc.tscn")
var ranged_orc = preload("res://Scenes/Mobs/ranged_orc.tscn")
var magic_orc = preload("res://Scenes/Mobs/magic_orc.tscn")

var monsters_instances = []

var player: CharacterBody2D = null

var monster_spawned_alive: int = 0

var monster_id: int

var destroyed: bool = false

@onready var main = get_tree().get_root().get_node("Main")

# Called when the node enters the scene tree for the first time.
func _ready():
	#player = get_parent().get_node("Player")
	randomize()
	
	$monster_respawn.start()
	print("Monster Spawner", global_position)
	$Sprite2D/AnimationPlayer.play("Idle")

func spawn_monster(monster_id):
	if monster_id == 0:
		var slime_instance = slime.instantiate()
		add_child(slime_instance)
	elif monster_id == 1:
		var melee_orc_instance = melee_orc.instantiate()
		add_child(melee_orc_instance)
	elif monster_id == 2:
		var ranged_orc_instance = ranged_orc.instantiate()
		add_child(ranged_orc_instance)
	elif monster_id == 3:
		var magic_orc_instance = magic_orc.instantiate()
		add_child(magic_orc_instance)
	elif monster_id == 4:
		var base_orc_instance = base_orc.instantiate()
		add_child(base_orc_instance)
	monster_spawned_alive += 1


func _on_hurt_box_area_entered(area):
	if area.name == "HitBox" and not destroyed:
		$Sprite2D.visible = false
		destroyed = true
		drop_loot()
		for mon in self.get_children():
			if mon.is_in_group("Monsters"):
				print(mon)
				mon.death()

func _on_monster_respawn_timeout():
	monster_id = randi_range(0,4)
	if monster_spawned_alive <= 3 and not destroyed:
		spawn_monster(monster_id) 


func _on_death_timer_timeout():
	queue_free()

func drop_loot():
	var lootQuantity = randi_range(15,30) 
	main.addGold(lootQuantity)
	main.addCrystals(lootQuantity)
	
