extends Control

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats

@onready var playerResources = get_tree().get_root().get_node("Main").playerResources

@onready var playerStatsLevel = get_tree().get_root().get_node("Main").trainStats

@onready var upgradeCostGold = get_tree().get_root().get_node("Main").upgradeCostGold

@onready var upgradeCostCrystal = get_tree().get_root().get_node("Main").upgradeCostCrystal

@onready var main = get_tree().get_root().get_node("Main")

# Called when the node enters the scene tree for the first time.
func _ready():
	upgradeStats()
	upgradePrices()
	main.actualizeResourcesSignal.connect(actualizeHoursAndDays)
	actualizeHoursAndDays()

func actualizeHoursAndDays():
	$MarginContainer/VBoxContainer/TopContainer/HoursRemaining.text = "Hours Remaining:\n" + str(playerResources.HoursRemaining)
	

func upgradePrices():
	#hpTraining
	if playerStatsLevel.HPLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/GameUIResources.visible = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Label2.visible = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Train.disabled = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Label.text = "Hp Training"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Train.text = "Train"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[playerStatsLevel.HPLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[playerStatsLevel.HPLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Label2.text = "Time: " +str(playerStatsLevel.HPLevel)+"h" 
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Label.text = "Hp Training Completed!"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Train.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Train.disabled = true
	
	#AtkTraining
	if playerStatsLevel.ATKLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/GameUIResources.visible = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Label2.visible = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Train.disabled = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Label.text = "ATK Training"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Train.text = "Train"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[playerStatsLevel.ATKLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[playerStatsLevel.ATKLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Label2.text = "Time: " +str(playerStatsLevel.ATKLevel)+"h" 
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Label.text = "ATK Training Completed!"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Train.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Train.disabled = true
			
	
	#SPDTraining
	if playerStatsLevel.SPDLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/GameUIResources.visible = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Label2.visible = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Train.disabled = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Label.text = "SPD Training"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Train.text = "Train"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[playerStatsLevel.SPDLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[playerStatsLevel.SPDLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Label2.text = "Time: " +str(playerStatsLevel.SPDLevel)+"h" 
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Label.text = "Speed Training Completed!"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Train.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Train.disabled = true
	
	

func upgradeStats():
	playerStats.MaxHp = playerStatsLevel.HPTraining[playerStatsLevel.HPLevel]
	playerStats.Atk = playerStatsLevel.ATKTraining[playerStatsLevel.ATKLevel]
	playerStats.Spd = playerStatsLevel.SPDTraining[playerStatsLevel.SPDLevel]
	$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelPlayerStats/PlayerStats/HP.text = "HP: " + str(playerStats.MaxHp)
	$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelPlayerStats/PlayerStats/Atk.text = "Atk: " + str(playerStats.Atk)
	$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelPlayerStats/PlayerStats/MovSpeed.text = "Spd: " + str(playerStats.Spd)
	
	
func _on_train_hp_pressed():
	if playerStatsLevel.HPLevel <= 5 and playerResources.Gold >= upgradeCostGold[playerStatsLevel.HPLevel] and playerResources.Crystals >= upgradeCostCrystal[playerStatsLevel.HPLevel] and playerResources.HoursRemaining >= playerStatsLevel.HPLevel:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Train.able = true
		main.loseGold(upgradeCostGold[playerStatsLevel.HPLevel])
		main.loseCrystals(upgradeCostCrystal[playerStatsLevel.HPLevel])
		main.loseHours(playerStatsLevel.HPLevel)
		playerStatsLevel.HPLevel += 1
		upgradePrices()
		if playerStatsLevel.HPLevel > 5:
			playerStatsLevel.HPLevel -= 1
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelHP/HPTraining/Train.able = false
	upgradeStats()


func _on_train_atk_pressed():
	if playerStatsLevel.ATKLevel <= 5 and playerResources.Gold >= upgradeCostGold[playerStatsLevel.ATKLevel] and playerResources.Crystals >= upgradeCostCrystal[playerStatsLevel.ATKLevel] and playerResources.HoursRemaining >= playerStatsLevel.ATKLevel:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Train.able = true
		main.loseGold(upgradeCostGold[playerStatsLevel.ATKLevel])
		main.loseCrystals(upgradeCostCrystal[playerStatsLevel.ATKLevel])
		main.loseHours(playerStatsLevel.ATKLevel)
		playerStatsLevel.ATKLevel += 1
		upgradePrices()
		if playerStatsLevel.ATKLevel > 5:
			playerStatsLevel.ATKLevel -= 1
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelATK/ATKTraining/Train.able = false
	upgradeStats()


func _on_train_spd_pressed():
	if playerStatsLevel.SPDLevel <= 5 and playerResources.Gold >= upgradeCostGold[playerStatsLevel.SPDLevel] and playerResources.Crystals >= upgradeCostCrystal[playerStatsLevel.SPDLevel] and playerResources.HoursRemaining >= playerStatsLevel.SPDLevel:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Train.able = true
		main.loseGold(upgradeCostGold[playerStatsLevel.SPDLevel])
		main.loseCrystals(upgradeCostCrystal[playerStatsLevel.SPDLevel])
		main.loseHours(playerStatsLevel.SPDLevel)
		playerStatsLevel.SPDLevel += 1
		upgradePrices()
		if playerStatsLevel.SPDLevel > 5:
			playerStatsLevel.SPDLevel -= 1
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/HBoxContainer/PanelTrainingOptions/MarginContainer/TrainingOptions/PanelSPD/SpeedTraining/Train.able = false
	upgradeStats()
