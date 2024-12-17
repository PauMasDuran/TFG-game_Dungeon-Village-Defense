extends Control

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats

@onready var playerResources = get_tree().get_root().get_node("Main").playerResources

@onready var playerStatsLevel = get_tree().get_root().get_node("Main").trainStats

@onready var upgradeCostGold = get_tree().get_root().get_node("Main").upgradeCostGold

@onready var upgradeCostCrystal = get_tree().get_root().get_node("Main").upgradeCostCrystal

@onready var main = get_tree().get_root().get_node("Main")

@onready var structures = get_tree().get_root().get_node("Main").structures

func _ready():
	upgradePrices()
	main.actualizeResourcesSignal.connect(actualizeHoursAndDays)
	actualizeHoursAndDays()

func actualizeHoursAndDays():
	$MarginContainer/VBoxContainer/HBoxContainer/HoursRemaining.text = "Hours Remaining:\n" + str(playerResources.HoursRemaining)

func upgradePrices():
	#Walls
	if structures.WallLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[structures.WallLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[structures.WallLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/Label2.text = "Time: " +str(structures.WallLevel)+"h" 
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/WallUpgradeButton.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/WallUpgradeButton.disabled = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/Label.text = "Wall Maxed Out!"
	
	#HealPad
	if structures.HealLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[structures.HealLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[structures.HealLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/Label2.text = "Time: " +str(structures.HealLevel)+"h" 

	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/HealPadUpgradeButton.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/HealPadUpgradeButton.disabled = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/Label.text = "HealPad Maxed Out!"
	
	#Decoy
	if structures.DecoyLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[structures.DecoyLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[structures.DecoyLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/Label2.text = "Time: " +str(structures.DecoyLevel)+"h" 

	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/DecoyUpgradeButton.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/DecoyUpgradeButton.disabled = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/Label.text = "Decoy Maxed Out!"
	
	#Turret
	if structures.ArcherLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[structures.ArcherLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[structures.ArcherLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/Label2.text = "Time: " +str(structures.ArcherLevel)+"h" 
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradestructuresOptions/PanelBoots/BootsUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradestructuresOptions/PanelBoots/BootsUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradestructuresOptions/PanelBoots/BootsUpgrade/Label2
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/TurretsUpgradeButton.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/TurretsUpgradeButton.disabled = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/Label.text = "Archers Maxed Out!"
	


func _on_wall_upgrade_button_pressed():
	if structures.WallLevel <= 5 and playerResources.Gold >= upgradeCostGold[structures.WallLevel] and playerResources.Crystals >= upgradeCostCrystal[structures.WallLevel] and playerResources.HoursRemaining >= structures.WallLevel:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/WallUpgradeButton.able = true
		main.loseGold(upgradeCostGold[structures.WallLevel])
		main.loseCrystals(upgradeCostCrystal[structures.WallLevel])
		main.loseHours(structures.WallLevel)
		structures.WallLevel += 1
		upgradePrices()
		if structures.WallLevel > 5:
			structures.WallLevel -= 1
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelWall/WallsUpgrade/WallUpgradeButton.able = false


func _on_heal_pad_upgrade_button_pressed():
	if structures.HealLevel <= 5 and playerResources.Gold >= upgradeCostGold[structures.HealLevel] and playerResources.Crystals >= upgradeCostCrystal[structures.HealLevel] and playerResources.HoursRemaining >= structures.HealLevel:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/HealPadUpgradeButton.able = true
		main.loseGold(upgradeCostGold[structures.HealLevel])
		main.loseCrystals(upgradeCostCrystal[structures.HealLevel])
		main.loseHours(structures.HealLevel)
		structures.HealLevel += 1
		upgradePrices()
		if structures.HealLevel > 5:
			structures.HealLevel -= 1
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelHealing/HealingPadUpgrade/HealPadUpgradeButton.able = false


func _on_decoy_upgrade_button_pressed():
	if structures.DecoyLevel <= 5 and playerResources.Gold >= upgradeCostGold[structures.DecoyLevel] and playerResources.Crystals >= upgradeCostCrystal[structures.DecoyLevel] and playerResources.HoursRemaining >= structures.DecoyLevel:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/DecoyUpgradeButton.able = true
		main.loseGold(upgradeCostGold[structures.DecoyLevel])
		main.loseCrystals(upgradeCostCrystal[structures.DecoyLevel])
		main.loseHours(structures.DecoyLevel)
		structures.DecoyLevel += 1
		upgradePrices()
		if structures.DecoyLevel > 5:
			structures.DecoyLevel -= 1
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelDecoy/DecoyUpgrade/DecoyUpgradeButton.able = false

func _on_turrets_upgrade_button_pressed():
	if structures.ArcherLevel <= 5 and playerResources.Gold >= upgradeCostGold[structures.ArcherLevel] and playerResources.Crystals >= upgradeCostCrystal[structures.ArcherLevel] and playerResources.HoursRemaining >= structures.ArcherLevel:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/TurretsUpgradeButton.able = true
		main.loseGold(upgradeCostGold[structures.ArcherLevel])
		main.loseCrystals(upgradeCostCrystal[structures.ArcherLevel])
		main.loseHours(structures.ArcherLevel)
		structures.ArcherLevel += 1
		upgradePrices()
		if structures.ArcherLevel > 5:
			structures.ArcherLevel -= 1
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeStructuresOptions/PanelTurret/TurretUpgrade/TurretsUpgradeButton.able = false
