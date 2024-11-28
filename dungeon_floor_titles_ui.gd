extends Control


func set_title(dungeonFloorNumber):
	var label = $ColorRect/DungeonFloorName
	if dungeonFloorNumber == 0:
		label.text = "Floor " + str(dungeonFloorNumber) +": "
	elif dungeonFloorNumber == 1:
		label.text = "Floor " + str(dungeonFloorNumber) +": "
	elif dungeonFloorNumber == 2:
		label.text = "Floor " + str(dungeonFloorNumber) +": "
	elif dungeonFloorNumber == 3:
		label.text = "Floor " + str(dungeonFloorNumber) +": "
