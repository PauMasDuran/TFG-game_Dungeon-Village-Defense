extends AudioStreamPlayer

@onready var menu_music = preload("res://Resources/MusicResources/HERO Epic Fantasy Orchestral Music Pack v1.1/Tracks WAV/07.2a Magical Place (less energy).wav")
@onready var dungeon_music = preload("res://Resources/MusicResources/HERO Epic Fantasy Orchestral Music Pack v1.1/Tracks WAV/03b The Ancient Fortress  [Loop].wav")
@onready var dungeon_boss_music = preload("res://Resources/MusicResources/HERO Epic Fantasy Orchestral Music Pack v1.1/Tracks WAV/06a The Stakes Are High.wav")
@onready var final_boss_music = preload("res://Resources/MusicResources/HERO Epic Fantasy Orchestral Music Pack v1.1/Tracks WAV/10 Final Chapter  [Loop].wav")

func play_menu_music():
	if stream != menu_music:
		stream = menu_music
		play()

func play_dungeon_music():
	if stream != dungeon_music:
		stream = dungeon_music
		play()

func play_dungeon_boss_music():
	if stream != dungeon_boss_music:
		stream = dungeon_boss_music
		play()

func play_final_boss_music():
	if stream != final_boss_music:
		stream = final_boss_music
		play()


func _on_finished():
	play()
