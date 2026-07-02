extends Node

var music_volume: float = 0.5:
	set(value):
		music_volume = clamp(value, 0.0, 1.0)
		var bus_idx = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))

var sfx_volume: float = 0.5:
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)
		var bus_idx = AudioServer.get_bus_index("SFX")
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))

var on_pause: bool = false

var pause_menu = null

func toggle_pause():
	if pause_menu == null:
		var menu_scene = preload("res://game/ui/pause_menu/pause_menu.tscn")
		pause_menu = menu_scene.instantiate()
		get_tree().root.add_child(pause_menu)
	pause_menu.visible = !pause_menu.visible
	if pause_menu.visible:
		pause_menu.sync_sliders() 
	on_pause = pause_menu.visible
	get_tree().paused = on_pause
