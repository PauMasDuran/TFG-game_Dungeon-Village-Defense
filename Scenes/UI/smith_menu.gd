extends Control

@onready var playerStats = get_tree().get_root().get_node("Main").playerStats

@onready var playerResources = get_tree().get_root().get_node("Main").playerResources

@onready var smith = get_tree().get_root().get_node("Main").smith

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
	$MarginContainer/VBoxContainer/HBoxContainer/HoursRemaining.text = "Hours Remaining:\n" + str(playerResources.HoursRemaining)

func upgradePrices():
	#SPCapacity
	if smith.SPLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[smith.SPLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[smith.SPLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/Label2.text = "Time: " +str(smith.SPLevel)+"h" 
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/ArmorUpgradeButton.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/ArmorUpgradeButton.disabled = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelArmor/ArmorUpgrade/Label.text = "Armor Maxed Out!"
	
	#SPDrain
	if smith.SPDrainLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[smith.SPDrainLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[smith.SPDrainLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/Label2.text = "Time: " +str(smith.SPDrainLevel)+"h" 
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/SwordUpgradeButton.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/SwordUpgradeButton.disabled = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/Label.text = "Sword Maxed Out!"
	
	$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelSword/SwordUpgrade/GameUIResources
	#SprintBoots
	if smith.SprintLevel < 5:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/GameUIResources/VBoxContainer/GoldContainer/GoldLabel.text = "= " + str(upgradeCostGold[smith.SprintLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/GameUIResources/VBoxContainer/CrystalContainer/CrystalLabel.text = "= " + str(upgradeCostCrystal[smith.SprintLevel])
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/Label2.text = "Time: " +str(smith.SprintLevel)+"h" 
	else:
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/GameUIResources.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/Label2.visible = false
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/BootsUpgradeButton.text = "Maxed"
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/BootsUpgradeButton.disabled = true
		$MarginContainer/VBoxContainer/Panel/MarginContainer/UpgradeSmithOptions/PanelBoots/BootsUpgrade/Label.text = "Boots Maxed Out!"



func upgradeStats():
	playerStats.MaxSp = smith.SPCapacity[smith.SPLevel]
	playerStats.SpDrain = smith.SPDrain[smith.SPDrainLevel]
	playerStats.SprintSpd = smith.SprintBoots[smith.SprintLevel]


func _on_sp_upgrade_button_pressed():
	if smith.SPLevel <= 5 and playerResources.Gold >= upgradeCostGold[smith.SPLevel] and playerResources.Crystals >= upgradeCostCrystal[smith.SPLevel] and playerResources.HoursRemaining >= smith.SPLevel:
		main.loseGold(upgradeCostGold[smith.SPLevel])
		main.loseCrystals(upgradeCostCrystal[smith.SPLevel])
		main.loseHours(smith.SPLevel)
		smith.SPLevel += 1
		upgradePrices()
		if smith.SPLevel > 5:
			smith.SPLevel -= 1
	upgradeStats()



func _on_drain_sp_upgrade_button_pressed():
	if smith.SPDrainLevel <= 5 and playerResources.Gold >= upgradeCostGold[smith.SPDrainLevel] and playerResources.Crystals >= upgradeCostCrystal[smith.SPDrainLevel] and playerResources.HoursRemaining >= smith.SPDrainLevel:
		main.loseGold(upgradeCostGold[smith.SPDrainLevel])
		main.loseCrystals(upgradeCostCrystal[smith.SPDrainLevel])
		main.loseHours(smith.SPDrainLevel)
		smith.SPDrainLevel += 1
		upgradePrices()
		if smith.SPDrainLevel > 5:
			smith.SPDrainLevel -= 1
	upgradeStats()


func _on_sprint_speed_upgrade_button_pressed():
	if smith.SprintLevel <= 5 and playerResources.Gold >= upgradeCostGold[smith.SprintLevel] and playerResources.Crystals >= upgradeCostCrystal[smith.SprintLevel] and playerResources.HoursRemaining >= smith.SprintLevel:
		main.loseGold(upgradeCostGold[smith.SprintLevel])
		main.loseCrystals(upgradeCostCrystal[smith.SprintLevel])
		main.loseHours(smith.SprintLevel)
		smith.SprintLevel += 1
		upgradePrices()
		if smith.SprintLevel > 5:
			smith.SprintLevel -= 1
	upgradeStats()
