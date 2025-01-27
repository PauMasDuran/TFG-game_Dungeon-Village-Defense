extends Control


func set_title(dungeonFloorNumber, is_dungeon_boss):
	var label = $ColorRect/DungeonFloorName
	if is_dungeon_boss:
		if dungeonFloorNumber == 0:
			label.text = "Floor " + str(dungeonFloorNumber) +" - Boss Room"
		elif dungeonFloorNumber == 1:
			label.text = "Floor " + str(dungeonFloorNumber) +" - Boss Room"
		elif dungeonFloorNumber == 2:
			label.text = "Floor " + str(dungeonFloorNumber) +" - Boss Room"
		elif dungeonFloorNumber == 3:
			label.text = "Floor " + str(dungeonFloorNumber) +" - Boss Room"
	else:
		if dungeonFloorNumber == 0:
			label.text = "Floor " + str(dungeonFloorNumber)
		elif dungeonFloorNumber == 1:
			label.text = "Floor " + str(dungeonFloorNumber) 
		elif dungeonFloorNumber == 2:
			label.text = "Floor " + str(dungeonFloorNumber) 
		elif dungeonFloorNumber == 3:
			label.text = "Floor " + str(dungeonFloorNumber)
