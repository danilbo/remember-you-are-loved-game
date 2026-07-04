extends Node

var current_level : int = 1

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

	if pause_menu.visible:
		# Меню уже видно — запускаем анимацию скрытия
		pause_menu.play_transition(false)
		# пауза снимется в _finish_hide() по окончании анимации
	else:
		# Ставим паузу сразу, меню начинает появляться
		get_tree().paused = true
		on_pause = true
		pause_menu.visible = true
		pause_menu.sync_sliders()
		pause_menu.play_transition(true)
