extends Node

var enemies_stats_dict = {
	"Slime": {
		"HP":10,
		"ATK": 10,
		"SPD": 60
	},
	"BaseOrc": {
		"HP":15,
		"ATK": 15,
		"SPD": 60
	},
	"MeleeOrc": {
		"HP":20,
		"ATK": 15,
		"SPD": 60
	},
	"RangedOrc": {
		"HP":10,
		"ATK": 15,
		"SPD": 80
	},
	"MagicOrc":{
		"HP":10,
		"ATK": 25,
		"SPD": 60
	},
	"BossSlime":{
		"HP":45,
		"ATK": 15,
		"SPD": 60
	}
}

var auraDict = {
	"green": {
		"buff": 1.2,
		"resource": preload("res://Scenes/Mobs/Auras/green_aura.tres")
	},
	"blue": {
		"buff": 1.5,
		"resource": preload("res://Scenes/Mobs/Auras/blue_aura.tres")
	},
	"red": {
		"buff": 2,
		"resource": preload("res://Scenes/Mobs/Auras/red_aura.tres")
	},
	"black": {
		"buff": 2.5,
		"resource": preload("res://Scenes/Mobs/Auras/black_aura.tres")
	},
	"none": {
		"buff": 1
	}
}


func actualize_power_level(monsterType,floorLevel,AuraLevel):
	floorLevel = get_floor_boost(floorLevel)
	var monster = get_parent()
	monster.speed = round(enemies_stats_dict[monsterType].SPD * floorLevel * auraDict[AuraLevel].buff)
	monster.atk = round(enemies_stats_dict[monsterType].ATK * floorLevel * auraDict[AuraLevel].buff)
	monster.health_points = round(enemies_stats_dict[monsterType].HP * floorLevel * auraDict[AuraLevel].buff)
	
	if AuraLevel != "none":
		monster.get_node("Aura").get_node("CPUParticles2D").color_ramp = auraDict[AuraLevel].resource
	else:
		monster.get_node("Aura").get_node("CPUParticles2D").emitting = false
		monster.get_node("Aura").visible = false

func get_floor_boost(floorLevel):
		match floorLevel:
			-1:
				return 1
			0:
				return 1
			1: 
				return 1.2
			2:
				return 1.5
			3:
				return 2
			_: 
				return 1
